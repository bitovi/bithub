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
          @instance.children += c
        end
      end
      if self.respond_to? :build_children
        @instance.children += build_children
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
      self
    end

    def associate_references
      if self.respond_to? :find_references
        @instance.references_to += find_references
      end
      if self.respond_to? :build_references
        @instance.references_to += build_references
      end
      self
    end

    def write_history
      @instance.events << @payload.instance if @payload.instance
    end

  end
end
