module Entities
  class Grouper
    def initialize(entity)
      @e = entity
    end

    def adopt(child_entities)
      child_entities.each do |e|
        e.parent = @e
      end if child_entities
      self
    end

    def join_family(parent_entity)
      @e.parent = parent_entity
      self
    end

    def reference(other_entities)
      @e.references += other_entities
      self
    end

    def caused_by(new_event)
      new_event.entity = new_entity
      self
    end
  end
end
