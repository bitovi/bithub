module Supervisors
  module Propagation

    def handle_message(msg)
      action        = msg.fetch(:action).to_sym
      message_scope = [msg[:brand], msg[:embed], msg[:service]].unshift('main').compact
      target = SupervisionNode.from_message message_scope

      handle_cmd(target, action)
    end

    def handle_cmd(target, action)
      if %i(stop restart).include?(action) && target_among_children?(target)
        execute_cmd(target, action)
      elsif action == :start && on_correct_level?(target)
        execute_cmd(target, action)
      else
        propagate_cmd(target, action)
      end
    end

    # Target is among my children
    def target_among_children?(target)
      !(children.select do |a|
        target.actor_name == a.name
      end).empty?
    end

    # I am supposed target's parent
    def on_correct_level?(target)
      target.parent.actor_name == name
    end

    # Action not meant for this level,
    # propagate further down
    def propagate_cmd(target, action)
      children.each do |c|
        if c.respond_to?(:handle_cmd, true)
          c.handle_cmd(target, action)
        end
      end
    end

    def children
      (respond_to?(:_childs, true) && !_childs.nil?) ? _childs.actors.compact : []
    end

    def children_names
      children.map { |a| a.name }
    end

    def terminate_cascading
      children.each { |c| c.terminate_cascading }
      terminate
    end
  end
end
