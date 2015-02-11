require_relative 'service'

module Supervisors
  class Embed
    include Celluloid
    include Propagation

    def initialize(path, embed_info)
      @path = SupervisionNode.new(path, embed_info)
      boot
    end

    def boot
      Celluloid.logger.info "Booting E #{@path.actor_name}"
      @services = SupervisionGroup.new
      embed_config.fetch(:services).each do |s|
        si = ServiceInfo.new(s.fetch(:id), s.fetch(:feed_name), s.fetch(:type_name))
        start_service_supervisor(si);
      end
    end

    def start_service_supervisor(si)
      @services.supervise_as(
        @path.next_level(si).actor_name,
        service_supervisor(si),
        *[@path, si]
      ) if service_supervisor(si)
    end

    def stop_service_supervisor(si)
      Celluloid.logger.info "Killing S #{@path.next_level(si).actor_name}"
      if (a = Actor[@path.next_level(si).actor_name])
        a.terminate_cascading
      end
    end

    def execute_cmd(target, action)
      if action == :stop
        stop_service_supervisor(target.node)
      elsif action == :start
        start_service_supervisor(target.node)
      elsif action == :restart
        stop_service_supervisor(target.node)
        start_service_supervisor(target.node)
      end
    end

    private

    def _childs; @services; end

    def embed_config
      Actor[:configurator].embed_config(*@path.rootless)
    end

    def service_supervisor(si)
      feed_name = si.feed_name.camel_case.to_sym
      type_name = si.type_name.camel_case.to_sym

      return unless Supervisors::Services.constants.include? feed_name
      return unless Supervisors::Services.const_get(feed_name).constants.include? type_name

      Supervisors::Services.const_get(feed_name).const_get(type_name)
    end
  end
end
