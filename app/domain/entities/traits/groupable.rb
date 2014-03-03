module Entities
  module Groupable

    def group
      join_family
      adopt
      associate_references
      write_history
      self
    end

    def adopt
      if self.respond_to? :find_children
        if (c = find_children)
          @instance.children += c.is_a?(Array) ? c : [c]
        end
      end

      if self.respond_to? :build_children
        @instance.children += build_children
      end

      if @instance.children
        update_from_children if self.respond_to? :update_from_children
      end

      self
    end

    def join_family
      if self.respond_to? :find_parent
        if (p = self.find_parent)
          @instance.parent = p
        end
      end

      if self.respond_to? :build_parent
        @instance.parent = build_parent
      end

      if @instance.parent
        update_parent if self.respond_to? :update_parent
      end

      self
    end

    def associate_references

      if self.respond_to? :find_references_from_self
        if (refs = find_references_from_self) #ENTITY
          if @instance.parent.present?
            @instance.parent.references_to += refs
          else
            @instance.references_to += refs
          end
        end
      end

      if self.respond_to? :find_references_to_self
        if (refs = find_references_to_self) #ENTITY
          if refs.reduce(false) {|acc, p| acc || p.parent.present?}
            @instance.referenced_from += refs.map {|r| (p = r.parent) ? p : r }.reject{|e| @instance.referenced_from.include?(e)}.uniq
          else
            @instance.referenced_from += refs
          end
        end
      end

      #if self.respond_to? :build_references
      #  @instance.references_to += build_references
      #end
      self
    end

    def write_history
      @instance.events << @event.instance if @event.instance
    end

  end
end
