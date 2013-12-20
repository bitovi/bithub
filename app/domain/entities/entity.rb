module Entities
  class Dispatcher

    def initialize(entity_persistor)
      @ep = entity_persistor
    end

    def judge(payload)
      entity_class = Entities.const_get(payload.feed).const_get(payload.type)


      entity = @ep.new(attrs)

      Builder.new.extract_attrs(payload)
      Determinator.new.determine(entity_instance)

      Grouper.new(entity_instance)

      entity_instance
      
      if e.fetch
        if e.isDirty?

        end
      end
    end
  end
end
