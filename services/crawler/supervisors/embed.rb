require 'supervisors/propagation'
require 'supervisors/supervision_node'
require 'supervisors/owner_data'
require 'supervisors/service'

module Supervisors
  class Embed
    include Celluloid
    include Propagation

    def initialize(path, embed_info, opts={})
      @path = SupervisionNode.new(path, embed_info)
      @services = SupervisionGroup.new
      @boot_on_init = opts.fetch(:boot_on_init) { false }
      boot(opts.fetch(:embed_config)) if boot_on_init?
    end

    def boot(embed_config)
      embed_config.fetch(:services).each do |s|

        si = NodeTypes::ServiceInfo.new(
          s.fetch(:id)\
          , s.fetch(:feed_name)\
          , s.fetch(:type_name)\
          , s.fetch(:config)\
        )

        if (ssc = service_supervisor_class(si))
          initialize_next_level_supervisor(si, ssc)
        else
          info "[EMBED_SUPERVISOR] Don't know how to boot service #{si}"
        end
      end
    end

    def handle_cmd(target, action)
      if (ssc = service_supervisor_class(target.node)) && target.node.is_a?(NodeTypes::ServiceInfo)
        if action == :start
          initialize_next_level_supervisor(target.node, ssc)
        elsif action == :stop
          terminate_next_level_supervisor(target.node)
        elsif action == :restart
          terminate_next_level_supervisor(target.node)
          initialize_next_level_supervisor(target.node, ssc)
        end
      else
        info "[EMBED_SUPERVISOR] Don't know how to handle commands for #{target.node}"
      end
    end

    private
    def _childs; @services; end

    def service_supervisor_class(si)
      feed_name = si.feed_name.camel_case.to_sym
      type_name = si.type_name.camel_case.to_sym

      return unless Supervisors::Services.constants.include? feed_name
      return unless Supervisors::Services.const_get(feed_name).constants.include? type_name

      Supervisors::Services.const_get(feed_name).const_get(type_name)
    end
  end
end
