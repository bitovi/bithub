module Supervisors
  module Propagation
    include Celluloid::Logger
    
    # Action not meant for this level,
    # propagate further down
    def propagate_cmd(target, action)
      children.each do |c|
        c.handle_cmd(target, action) if c.respond_to?(:handle_cmd, true)
      end
    end
    
    def initialize_next_level_supervisor(node_info, actor_class)
      info "Starting next level #{@path.next_level(node_info).actor_name}"
      @brands.supervise_as(
        (actor_name = @path.next_level(node_info).actor_name),
        actor_class,
        *[@path, node_info]
      )
      debug "#{name}: #{children_names}"
      actor_name
    end
    
    def terminate_next_level_supervisor(bi)
      info "Killing next level #{@path.next_level(bi).actor_name}"
      if (a = Actor[@path.next_level(bi).actor_name])
        a.terminate_cascading
      end
      debug "#{name}: #{children_names}"
    end

    def among_children?(target)
      children_names.include?(target.actor_name)
    end
    
    def i_am_parent?(target)
      target.parent.actor_name == name
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
