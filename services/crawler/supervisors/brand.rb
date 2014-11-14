require_relative 'embed'

module Supervisors
  class Brand
    include Celluloid
    include Common

    def initialize(bn)
      @current_level = [@brand_name = bn]
      Celluloid.logger.info "Booting #{@current_level}"
      boot
    end

    def boot
      @embeds = SupervisionGroup.new
      brand_config.fetch(:embeds).each do |e|
        start_embed_supervisor(e.fetch(:name))
      end
    end

    def restart_embed_supervisor(embed_name)
      stop_embed_supervisor(embed_name)
      start_embed_supervisor(embed_name)
    end

    def start_embed_supervisor(embed_name)
      Celluloid.logger.info "Starting #{child_name(embed_name)}"
      @embeds.supervise_as(
        child_name(embed_name),
        Supervisors::Embed,
        *[@brand_name, embed_name]
      )
    end

    def stop_embed_supervisor(embed_name)
      if (a = Celluloid::Actor[child_name(embed_name)])
        a.terminate
      end
    end

    private

    def brand_config
      Celluloid::Actor[:configurator].brand_config(@brand_name)
    end
  end
end
