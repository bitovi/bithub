module Entities
  module Groupable

    def group
      join_family
      adopt
      reference
      self
    end

    def adopt
      procure_children.andand.each do |child|
        child.parent = @instance
      end
      self
    end

    def join_family
      @instance.parent = procure_parent
      self
    end

    def reference
      @instance.references += procure_references
      self
    end

  end
end


