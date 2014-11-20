require_relative 'service'

module Supervisors
  class Embed
    include Celluloid

    def initialize(path, en)
      @path = TreePath.new(path, @embed_name = en, :embed_name)
      Celluloid.logger.info "Booting #{@path.actor_name}"
      boot
    end

    def boot
      @services = SupervisionGroup.new
      embed_config.fetch(:services).each do |s|
        si = ServiceInfo.new(s[:feed_name], s[:type_name])
        start_service_supervisor(si);
      end
    end
    
    def restart_service_supervisor(si)
      stop_embed_supervisor(si)
      start_embed_supervisor(si)
    end

    def start_service_supervisor(si)
      @services.supervise_as(
        @path.child_actor_name(si.name),
        service_supervisor(si.name),
        *[@path, si]
      )
    end

    def stop_service_supervisor(si)
      if (a = Celluloid::Actor[@path.child_actor_name(si.name)])
        a.terminate
      end
    end

    private

    def embed_config
      Celluloid::Actor[:configurator].embed_config(*@path.rootles_path)
    end

    def service_supervisor(sn)
      const_name = sn.camel_case.to_sym
      Supervisors::Services.const_get(const_name)
    end
  end
end
