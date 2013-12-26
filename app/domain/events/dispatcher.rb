require 'andand'
require 'lib/core_ext'

require 'entities/procurer'
require 'events/shared/mappings'

# Feeds
require 'events/feeds/blog/blog'
require 'events/feeds/disqus/disqus'
require 'events/feeds/forum/forum'
require 'events/feeds/github/github'
require 'events/feeds/twitter/twitter'

module Events
  class Dispatcher
    include Events::Mappings

    def initialize(event_persistor, entity_persistor)
      initialize_logger
      @evp = event_persistor
      @enp = entity_persistor
    end

    def dispatch(payload)
      @logger.debug "IN DISPATCHER"

      # @logger.debug "RAW PAYLOAD"
      # @logger.debug payload.inspect

      full_name, feed_name, type_name = names(subtype(payload).to_s)

      new_event = @evp.new({
        feed: feed_name,
        type: type_name,
        content_digest: payload['content_digest'],
        source_data: payload['source_data'],
        source_json: payload['source_json'],
      })
      
      @logger.debug "NEW event"
      @logger.debug new_event.inspect

      procurer = Entities::Procurer.new(@enp)
      new_entity = procurer.procure(new_event)

      @logger.debug "NEW entity"
      @logger.debug new_entity.inspect

      # related_entities = entity_class.procure_related(payload)
      # new_or_updated_entities = [base_entity] + related_entities

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
      event_class.to_s.match(/.*::(.*)::(.*)/).to_a
    end

    def initialize_logger
      @logger = Log4r::Logger.new('Dispatcher')
      @logger.add(Log4r::StdoutOutputter.new('console', {
        :formatter => Log4r::PatternFormatter.new(:pattern => "[#{Process.pid}:%l] %d :: %m")
      }))
    end
  end
end
