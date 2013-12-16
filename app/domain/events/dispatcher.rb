require 'andand'

# Require all Event types
Dir[File.join('app', 'domain', 'events', 'types', '**', '*.rb')].each do |f|
  require f.gsub('app/domain/', '')
end

module Events
  class UnknownFeedException < Exception; end
  class UnknownTypeException < Exception; end

  class Dispatcher
    attr_reader :payload

    def initialize(event_persistor, entity_persistor)
      @event_persistor = event_persistor
      @entity_persistor = entity_persistor
    end

    def process(payload)
      @event_persistor.persist(build_self(payload))

      @entities = []
      @entities += entities_to_update
      @entities += entities_to_create

      @entities.each do |e|
        @entity_persistor.create(e) if e.create?
        @entity_persistor.update(e) if e.update?
      end
    end

    # Delegation
    def build_self(payload)
      subtype.build_self(payload)
    end

    def entities_to_update
      subtype.entities_to_update(payload)
    end

    def entities_to_create
      subtype.entities_to_create(payload)
    end

    def subtype(payload)
      meta = (payload['meta'] || payload[:meta])
      fail Events::UnknownFeedException unless meta[:feed]
      fail Events::UnknownTypeException unless meta[:type]

      meta[:type] = remap_meta_type(meta[:type])
      
      module_name = meta[:feed].camel_case
      class_name = meta[:type].gsub('_event', '').camel_case

      # puts "module_name: #{module_name}"
      # puts "class_name: #{class_name}"

      if (m = Events.const_get(module_name))
        #puts "MODULE: #{m}"
        if (c = m.const_get(class_name))
          #puts "CLASS: #{c}"
          return c
        else
          fail Events::UnknownTypeException
        end
      else
        fail Events::UnknownFeedException
      end
    end

    def remap_meta_type(meta_type)
      case meta_type
      when 'status_event' then 'tweet'
      when 'issues_event' then 'issue_event'
      else meta_type
      end
    end
  end
end
