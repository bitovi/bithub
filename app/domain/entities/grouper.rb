module Entities
  class Grouper
    def initialize(entity)
      @e = entity
    end

    def group
      join_family
      adopt
      reference
    end

    def adopt
      @e.procure_children.andand.each do |c|
        c.parent = @e.instance
      end
      self
    end

    def join_family
      @e.instance.parent = @e.procure_parent
      self
    end

    def reference
      # @e.insreferences += @e.references
      self
    end

    # def caused_by
    #   # @e.instance= @e.new_entity
    #   self
    # end
  end
end
