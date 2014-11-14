require_relative 'brand'

module Supervisors
  class Main
    include Celluloid
    include Common

    def initialize
      @current_level = []
      Celluloid.logger.info "Booting #{@current_level}"
      boot
    end

    def boot
      @brands = SupervisionGroup.new
      config.fetch(:brands).each do |b|
        start_brand_supervisor(b.fetch(:name))
      end
    end

    def restart_brand_supervisor(brand_name)
      stop_brand_supervisor(brand_name)
      start_brand_supervisor(brand_name)
    end

    def start_brand_supervisor(brand_name)
      @brands.supervise_as(
        child_name(brand_name),
        Supervisors::Brand,
        *[brand_name]
      )
    end

    def stop_brand_supervisor(brand_name)
      if (a = Celluloid::Actor[child_name(brand_name)])
        a.terminate
      end
    end

    def reload_brand_feed(brand_name, feed_name)
      Celluloid::Actor[:configurator].reload

      if Celluloid::Actor[child_name(brand_name)].respond_to? :reload_feed
        Celluloid.logger.info "Reloading #{child_name(brand_name)}"
        Celluloid::Actor[child_name(brand_name)].reload_feed(feed_name)
      else
        restart_brand(brand_name)
      end
    end
    
    private

    def config
      Celluloid::Actor[:configurator].config
    end
  end
end
