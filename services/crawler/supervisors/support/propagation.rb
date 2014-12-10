module Supervisors
  module Propagation
    def handle_cmd(path, action)
      if target_among_children?(path)
        Celluloid.logger.info "Executing #{action} for #{path}"
        execute_cmd(path, action)
      else
        propagate_cmd(path, action)
      end
    end

    def target_among_children?(path)
      !(children.select do |a|
        path.actor_name == a.name
      end).empty?
    end

    def propagate_cmd(path, action)
      children.each do |b|
        b.handle_cmd(path, action)
      end
    end
    
    def children
      _childs.actors.compact
    end
    
    def children_names
      children.map {|a| a.name}
    end
  end
end
