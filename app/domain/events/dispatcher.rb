require 'andand'
require 'lib/core_ext'
require 'app/domain/events/shared/mappings'

# Require all Event types
Dir[File.join('app', 'domain', 'events', 'feeds', '**', '*.rb')].each do |f|
  require f.gsub('app/domain/', '')
end

module Events
  class Dispatcher
    include Events::Mappings

    def initialize(event_persistor, entity_persistor)
      initialize_logger
      @evp = event_persistor
      @enp = entity_persistor
    end

    def process(payload)
      event_class = subtype(payload).to_s
      full_name, feed_name, type_name = names(event_class)

      new_event = @evp.new({
        feed: feed_name,
        type: type_name,
        content_digest: payload['content_digest'],
        source_data: payload['source_data'],
        source_json: payload['source_json'],
        extracted: payload['extracted'],
      })

      entity_class = Entities::Procurer.new(@enp).dispatch(payload)

      base_entity = entity_class.find_or_build(payload)
      related_entities = entity_class.find_or_build_related(payload)

      new_or_updated_entities = [base_entity] + related_entities

      # ActiveRecord::Base.transaction do
      #   new_event.save!
      #   new_or_updated_entities.each { |e| entity.save! }
      # end
    end

    def entity_class(event_class)
      _, feed_name, type_name = names(event_class)
      Entities.const_get(feed_name).const_get(type_name)
    end


    def subtype(payload)
      meta = (payload['meta'] || payload[:meta])
      fail Events::Errors::UnknownFeedException unless meta['feed']
      fail Events::Errors::UnknownTypeException unless meta['type']

      meta['type'] = type_mappings(meta['type'])
      meta['feed'] = feed_mappings(meta['feed'])

      module_name = meta['feed'].camel_case
      class_name = meta['type'].gsub('_event', '').camel_case

      if (m = Events.const_get(module_name))
        if (c = m.const_get(class_name))
          return c
        else
          fail Events::Errors::UnknownFeedException
        end
      else
        fail Events::Errors::UnknownFeedException
      end
    end

    def names(event_class)
      event_class.match(/Event::(.*)::(.*)/).to_a
    end

    def initialize_logger
      @logger = Log4r::Logger.new('Dispatcher')
      @logger.add(Log4r::StdoutOutputter.new('console', {
        :formatter => Log4r::PatternFormatter.new(:pattern => "[#{Process.pid}:%l] %d :: %m")
      }))
    end
  end
end
