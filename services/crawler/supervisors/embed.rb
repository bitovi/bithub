require_relative 'service'

module Supervisors
  class Embed
    include Celluloid
    include Common

    def initialize(bn, en)
      @current_level = [@brand_name=bn, @embed_name=en]
      Celluloid.logger.info "Booting #{@current_level}"
      boot
    end

    def boot
      @services = SupervisionGroup.new
      embed_config.fetch(:services).each do |s|
        start_service_supervisor(s.fetch(:feed_name))
      end
    end
    
    def restart_service_supervisor(service_name)
      stop_embed_supervisor(service_name)
      start_embed_supervisor(service_name)
    end

    def start_service_supervisor(service_name)
      Celluloid.logger.info "Starting #{child_name(service_name)}"
      @services.supervise_as(
        child_name(service_name),
        service_supervisor(service_name),
        *[@brand_name, @embed_name, service_name]
      )
    end

    def stop_service_supervisor(service_name)
      if (a = Celluloid::Actor[child_name(service_name)])
        a.terminate
      end
    end

    private

    def embed_config
      Celluloid::Actor[:configurator].embed_config(@brand_name, @embed_name)
    end

    def service_supervisor(service_name)
      const_name = service_name.to_s.camel_case.to_sym
      Supervisors::Services.const_get(const_name)
    end

  end
end
