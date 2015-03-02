require 'supervisors/service'

module Supervisors
  class Embed
    include Celluloid
    include Propagation

    def initialize(path, embed_info)
      @path = SupervisionNode.new(path, embed_info)
      @services = SupervisionGroup.new
    end

    def boot(embed_config)
      embed_config.fetch(:services).each do |s|
        si = ServiceInfo.new(
          s.fetch(:id)
          , s.fetch(:feed_name)
          , s.fetch(:type_name)
          , s.fetch(:config)
        )

        if (ssc = service_supervisor_class(si))
          actor_name = initialize_next_level_supervisor(si, ssc)
          Actor[actor_name].boot(s)
        else
          info "Don't know how to boot service #{si}"
        end
      end
    end

    def handle_cmd(target, action)
      if (ssc = service_supervisor_class(target.service))
        if action == :start && !among_children?(target.service)
          initialize_next_level_supervisor(target.service, ssc)
        elsif action == :stop
          terminate_next_level_supervisor(target.service)
        elsif action == :restart
          terminate_next_level_supervisor(target.service)
          initialize_next_level_supervisor(target.service, ssc)
        end
      else
        info "Don't know how to handle service #{target.service}"
      end
    end

    private
    def _childs; @services; end

    def service_supervisor(si)
      feed_name = si.feed_name.camel_case.to_sym
      type_name = si.type_name.camel_case.to_sym

      return unless Supervisors::Services.constants.include? feed_name
      return unless Supervisors::Services.const_get(feed_name).constants.include? type_name

      Supervisors::Services.const_get(feed_name).const_get(type_name)
    end
  end
end
