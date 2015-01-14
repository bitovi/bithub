module Supervisors
  module Propagation
    def handle_cmd(target, action)
      Celluloid.logger.debug "#handle_cmd, me: #{self.name}, target: #{target}"
      if %i(stop restart).include?(action) && target_among_children?(target)
        Celluloid.logger.info "Executing #{action} for #{target}"
        execute_cmd(target, action)
      elsif action == :start && on_correct_level?(target)
        Celluloid.logger.info "Executing #{action} for #{target}"
        execute_cmd(target, action)
      else
        Celluloid.logger.info "Propagating further down..."
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
      Celluloid.logger.debug "Childs: #{children_names}"
      children.each do |c|
        c.handle_cmd(target, action)
      end
    end

    def children
      (respond_to?(:_childs, true) && !_childs.nil?) ? _childs.actors.compact : []
    end
    
    def children_names
      children.map { |a| a.name }
    end
    
    def shutyoself
      children.each { |c| c.shutyoself }
      terminate
    end
  end
end
