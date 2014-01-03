require 'andand'
require 'lib/core_ext'
require 'lib/loggable'

require 'entities/procurer'
require 'entities/determinator'
require 'events/shared/mappings'

# Feeds
require 'events/feeds/blog/blog'
require 'events/feeds/disqus/disqus'
require 'events/feeds/forum/forum'
require 'events/feeds/github/github'
require 'events/feeds/twitter/twitter'

module Events
  class Dispatcher
    include Loggable
    include Events::Mappings

    def initialize(event_persistor, entity_persistor)
      initialize_logger
      @evp = event_persistor
      @enp = entity_persistor
    end

    def dispatch(payload)
      # @logger.debug "NEW payload"
      # @logger.debug payload.inspect

      full_name, feed_name, type_name = names(subtype(payload).to_s)

      new_event = @evp.new({
        feed: feed_name,
        type: type_name,
        content_digest: payload['content_digest'],
        source_data: payload['source_data'],
        source_json: payload['source_json'],
      })
      
      # @logger.debug "NEW event"
      # @logger.debug new_event.inspect
      
      procurer = Entities::Delegator.new(@enp).procurer(payload)
      new_entity = procurer.procure(payload)

      upstream_entities = procurer.find_or_build_upstream(payload)
      downstream_entities = procurer.find_or_build_upstream(payload)
      referenced_entities = procurer.find_referenced(payload)

      Entities::Determinator.new(new_entity).determine
      Entities::Normalizer.new(new_entity).normalize
      Entities::Grouper.new(new_entity)
      .join_family(upstream_entity)
      .adopt(downstream_entities)
      .reference(referenced_entities)

      # @logger.debug "NEW entity"
      # @logger.debug new_entity.inspect
      
      ActiveRecord::Base.transaction do
        new_event.save!
        new_entity.save!
        upstream_entity.save!
        downstream_entities.each {|e| e.save!}
        referenced_entities.each {|e| e.save!}
      end
    end

    def subtype(payload)
      meta = (payload['meta'] || payload[:meta])
      fail Events::Errors::UnknownFeedException unless meta['feed']
      fail Events::Errors::UnknownTypeException unless meta['type']

      feed_name, type_name = switch_to_camel_case(meta)

      @logger.debug "Dispatcher#subtype, feed:#{feed_name}, type:#{type_name}"

      if (m = Events.const_get(feed_name))
        if (c = m.const_get(type_name))
          return c
        else
          fail Events::Errors::UnknownTypeException
        end
      else
        fail Events::Errors::UnknownFeedException
      end
    end

    def names(event_class)
      event_class.to_s.match(/.*::(.*)::(.*)/).to_a
    end

  end
end
