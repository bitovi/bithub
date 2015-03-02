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
        ei = EmbedInfo.new(e.fetch(:id), e.fetch(:name))
        actor_name = initialize_next_level_supervisor(ei, Supervisors::Embed)
        Actor[actor_name].boot(e)
      end
    end

    def handle_cmd(target, action)
      if action == :start
        if !among_children?(target.embed)
          initialize_next_level_supervisor(target.embed, Supervisors::Embed)
        end
        propagate_cmd(target, action)
      elsif action == :stop
        terminate_next_level_supervisor(target.embed)
      elsif action == :restart
        propagate_cmd(target, restart)
      end
    end

    private
    def _childs; @embeds; end
  end
end
