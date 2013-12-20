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
      @logger.debug event_class.inspect

      full_name, feed, type = event_class.match(/Event::(.*)::(.*)/).to_a

      new_event = @evp.new({
        feed: feed,
        type: type,
        content_digest: payload['content_digest'],
        source_data: payload['source_data'],
        source_json: payload['source_json'],
        extracted: payload['extracted'],
      })

      new_or_updated_entities = Entities::Dispatcher.new(@enp).process(new_event)

      # ActiveRecord::Base.transaction do
      #   new_event.save!
      #   new_or_updated_entities.each { |e| entity.save! }
      # end
    end
    
    # def entities_to_update
    #   subtype.entities_to_update(payload)
    # end

    # def entities_to_create
    #   subtype.entities_to_create(payload)
    # end

    # def subtype_name(payload)
    #   subtype(payload).to_s.gsub(/Events::.*::/, '')
    # end

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

    def initialize_logger
      @logger = Log4r::Logger.new('Dispatcher')
      @logger.add(Log4r::StdoutOutputter.new('console', {
        :formatter => Log4r::PatternFormatter.new(:pattern => "[#{Process.pid}:%l] %d :: %m")
      }))
    end
  end
end
