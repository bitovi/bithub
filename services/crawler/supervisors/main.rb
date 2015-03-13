require 'supervisors/propagation'
require 'supervisors/supervision_node'
require 'supervisors/owner_data'
require 'supervisors/brand'

module Supervisors
  class Main
    include Celluloid
    include Propagation

    def initialize(opts={})
      @path = SupervisionNode.new(nil, NodeTypes::MainInfo.new)
      @brands = SupervisionGroup.new
      @boot_on_init = opts.fetch(:boot_on_init) { true }
      boot(config_tree) if boot_on_init?
    end

    def boot(whole_config)
      info "Starting ROOT/MAIN supervisor"
      info whole_config.to_yaml

      whole_config.fetch(:brands).each do |b|
        bi = NodeTypes::BrandInfo.new(b.fetch(:id), b.fetch(:name))
        actor_name = initialize_next_level_supervisor(bi, Supervisors::Brand)
        Actor[actor_name].boot(b)
      end

      info "#{name} Confirming that boot proces is done"
      @booted = true
    end

    def booted?
      @booted || false
    end
    
    def handle_msg(msg)
      action = msg.fetch(:action).to_sym
      leaf = SupervisionNode.from_message(msg)
      handle_cmd(leaf, action)
    end

    def handle_cmd(target, action)
      if target.node.is_a?(NodeTypes::BrandInfo)
        if action == :start
          initialize_next_level_supervisor(target.node, Supervisors::Brand)
        elsif action == :stop
          terminate_next_level_supervisor(target.node)
        end
      else
        propagate_cmd(target, action)
      end
      # debug "#{target.brand} is #{name}'s children? #{among_children?(target.brand)}"
      # initialize_next_level_supervisor(target.brand, Supervisors::Brand) if !among_children?(target.brand)
    end

    def config_tree
      @config_tree ||= Actor[:configurator].config
    end

    private
    def _childs; @brands; end
  end
end
