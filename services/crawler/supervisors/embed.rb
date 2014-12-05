require_relative 'service'

module Supervisors
  class Embed
    include Celluloid
    include Propagation

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
    
    def start_service_supervisor(si)
      @services.supervise_as(
        @path.child_actor_name(si.name),
        service_supervisor(si),
        *[@path, si]
      )
    end

    def stop_service_supervisor(si)
      if (a = Celluloid::Actor[@path.child_actor_name(si.name)])
        a.terminate
      end
    end
    
    def execute_cmd(path, action)
      if action == :stop
        stop_service_supervisor(path.service_info)
      end
    end

    private

    def _childs; @services; end

    def embed_config
      Celluloid::Actor[:configurator].embed_config(*@path.rootles_path)
    end

    def service_supervisor(si)
      Supervisors::Services
        .const_get(si.feed_name.camel_case.to_sym)
        .const_get(si.type_name.camel_case.to_sym)
    end
  end
end
