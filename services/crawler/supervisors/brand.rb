require 'supervisors/embed'

module Supervisors
  class Brand
    include Celluloid
    include Propagation

    def initialize(path, brand_info)
      @path = SupervisionNode.new(path, brand_info)
      @embeds = SupervisionGroup.new
    end

    def boot(brand_config)
      brand_config.fetch(:embeds).each do |e|
        ei = NodeTypes::EmbedInfo.new(e.fetch(:id), e.fetch(:name))
        actor_name = initialize_next_level_supervisor(ei, Supervisors::Embed)
        Actor[actor_name].boot(e)
      end
    end

    def handle_cmd(target, action)
      if target.node.is_a?(NodeTypes::EmbedInfo)
        if action == :start
          initialize_next_level_supervisor(target.node, Supervisors::Embed)
        elsif action == :stop
          terminate_next_level_supervisor(target.node)
        end
      else
        propagate_cmd(target, action)
      end
      # debug "#{target.embed} is #{name}'s children? #{among_children?(target.embed)}"
      # initialize_next_level_supervisor(target.embed, Supervisors::Embed) if !among_children?(target.embed)
    end

    private
    def _childs; @embeds; end
  end
end
