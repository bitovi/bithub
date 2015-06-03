require 'colorize'

module Supervisors
  module Propagation
    include Celluloid::Logger

    # Action not meant for this level,
    # propagate further down where routing
    # matches (where target matches their name)
    def propagate_cmd(target, action)
      children.select do |c|
        target_path = target.to_s.split(SupervisionNode::SEPARATOR)
        current_actor_path = c.name.to_s.split(SupervisionNode::SEPARATOR)

        (target_path & current_actor_path).length == current_actor_path.length
      end.each do |c|
        c.handle_cmd(target, action) if c.respond_to?(:handle_cmd, true)
      end
    end

    def initialize_next_level_supervisor(node_info, actor_class)
      debug "STARTING #{node_info.to_s.colorize(:red)}"
      _childs.supervise_as(
        (actor_name = @path.next_level(node_info).actor_name),
        actor_class,
        *[@path, node_info]
      )
      debug "STARTED #{node_info.to_s.colorize(:red)} in #{name.to_s.colorize(:blue)} which now has #{children_names.to_s.colorize(:green)}"

      actor_name
    end

    def terminate_next_level_supervisor(node_info)
      # info "Killing next level #{@path.next_level(bi).actor_name}"

      debug "TERMINATING #{node_info.to_s.colorize(:red)}"
      if (a = Celluloid::Actor[@path.next_level(node_info).actor_name])
        a.terminate_cascading
      end
      debug "TERMINATED #{node_info.to_s.colorize(:red)} in #{name.to_s.colorize(:blue)} which now has #{children_names.to_s.colorize(:green)}"

      nil
    end

    def among_children?(node)
      children_names.include?(@path.next_level(node).actor_name)
    end

    def i_am_parent?(node)
      node.parent.actor_name == name
    end

    def children
      (respond_to?(:_childs, true) && !_childs.nil?) ? _childs.actors.compact : []
    end

    def children_names
      children.map { |a| a.name }
    end

    def terminate_cascading
      children.each { |c| c.terminate_cascading }
      self.cleanup if respond_to? :cleanup
      terminate
    end

    def boot_on_init?
      @boot_on_init
    end
  end
end
