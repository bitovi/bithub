module Entities
  class Grouper
    def initialize(entity)
      @e = entity
    end

    def adopt(child_entities)
      child_entities.each do |e|
        e.parent = @e
      end
    end

    def join_family(parent_entity)
      @e.parent = parent_entity
    end

    def reference(other_entities)
      @e.referenced += other_entities
    end
  end
end
