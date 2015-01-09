module Supervisors
  module Propagation
    def handle_cmd(target, action)
      if %i(stop restart).include?(action) && target_among_children?(target)
        Celluloid.logger.info "Executing #{action} for #{target}"
        execute_cmd(target, action)
      elsif action == :start && on_correct_level?(target)
        Celluloid.logger.info "Executing #{action} for #{target}"
        execute_cmd(target, action)
      elsif !final_level?
        propagate_cmd(target, action)
      end
    end

    # Target is among my children
    def target_among_children?(target)
      !(children.select do |a|
        target.actor_name == a.name
      end).empty?
    end
    
    # I am target's supposed parent
    def on_correct_level?(target)
      target.parent.actor_name == name
    end
    
    # Final level is service level. Don't
    # propagate further down than that.
    def final_level?
      name =~ /service/
    end
    

    # Action not meant for this level,
    # propagate further down
    def propagate_cmd(target, action)
      children.each do |c|
        c.handle_cmd(target, action)
      end
    end

    def children
      _childs.actors.compact
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
