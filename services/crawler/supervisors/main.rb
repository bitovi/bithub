require_relative 'brand'
require_relative 'support/tree_path'
require_relative 'support/service_info'

module Supervisors
  class Main
    include Celluloid

    def initialize
      @path = TreePath.new(nil, 'main', :root)
      Celluloid.logger.info "Booting #{@path.actor_name}"
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
        @path.child_actor_name(brand_name),
        Supervisors::Brand,
        *[@path, brand_name]
      )
    end

    def stop_brand_supervisor(brand_name)
      if (a = Celluloid::Actor[@path.child_actor_name(brand_name)])
        a.terminate
      end
    end

    def reload_brand_feed(brand_name, feed_name)
      Celluloid::Actor[:configurator].reload

      if Celluloid::Actor[@path.child_actor_name(brand_name)].respond_to? :reload_feed
        Celluloid.logger.info "Reloading #{@path.child_actor_name(brand_name)}"
        Celluloid::Actor[@path.child_actor_name(brand_name)].reload_feed(feed_name)
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
