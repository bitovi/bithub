module Entities
  module Groupable

    def group
      join_family
      adopt
      reference
      self
    end

    def adopt
      if self.respond_to? :find_children
        find_children.andand.each { |child| child.parent = @instance }
      elsif self.respond_to? :build_children
        build_children.andand.each { |child| child.parent = @instance }
      end
      self
    end

    def join_family
      if self.respond_to? :find_parent
        @instance.parent = find_parent
      elsif self.respond_to? :build_parent
        @instance.parent = build_parent
      end
      self
    end

    def reference
      if self.respond_to? :find_references
        @instance.referenced += find_references
      elsif self.respond_to? :build_references
        @instance.referenced += build_references
      end
      self
    end

  end
end


