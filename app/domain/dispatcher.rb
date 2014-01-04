require 'andand'
require 'lib/core_ext'
require 'lib/loggable'

require 'payload/payload'

require 'entities/procurer'
require 'entities/determinator'
require 'entities/grouper'
require 'events/shared/mappings'

# Feeds
require 'events/feeds/blog/blog'
require 'events/feeds/disqus/disqus'
require 'events/feeds/forum/forum'
require 'events/feeds/github/github'
require 'events/feeds/twitter/twitter'

class Dispatcher
  include Loggable

  def initialize(event_persistor, entity_persistor)
    initialize_logger
    @evp = event_persistor
    @enp = entity_persistor
  end

  def dispatch(payload)
    # @logger.debug "NEW payload"
    # @logger.debug payload.inspect

    payload = Payload.new(payload)

    new_event = @evp.new({
      feed: payload.feed,
      type: payload.type,
      content_digest: payload.content_digest,
      source_data: payload.source_data,
    })

    # @logger.debug "NEW event"
    # @logger.debug new_event.inspect

    procurer = Entities::Procurer.new(@enp, payload)

    new_entity          = procurer.procure(payload)
    upstream_entity     = procurer.procure_upstream(payload)
    downstream_entities = procurer.procure_downstream(payload)
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
end
