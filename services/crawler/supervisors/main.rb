require 'supervisors/propagation'
require 'supervisors/supervision_node'
require 'supervisors/brand'

module Supervisors
  class Main
    include Celluloid
    include Propagation

    def initialize
      @path = SupervisionNode.new(nil, MainInfo.new)
      @brands = SupervisionGroup.new
    end

    def boot
      info "Starting ROOT/MAIN supervisor"
      info config_tree

      config_tree.fetch(:brands).each do |b|
        bi = BrandInfo.new(b.fetch(:id), b.fetch(:name))
        actor_name = initialize_next_level_supervisor(bi, Supervisors::Brand)
        Actor[actor_name].boot(b)
      end
    end

    def handle_cmd(target, action)
      if action == :start
        if !among_children?(target.brand)
          initialize_next_level_supervisor(target.brand, Supervisors::Brand)
        end
        propagate_cmd(target, action)
      elsif action == :stop
        terminate_next_level_supervisor(target.brand)
      elsif action == :restart
        propagate_cmd(target, action)
      end
    end

    def config_tree
      @config_tree ||= Actor[:configurator].config
    end

    private
    def _childs; @brands; end
  end
end
