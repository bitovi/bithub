require 'andand'
require 'lib/core_ext'
require 'lib/core_helpers'
require 'lib/loggable'

require 'events/payload'

require 'entities/procurer'
require 'entities/determinator'
require 'entities/grouper'

class Dispatcher
  include Loggable

  def initialize(event_persistor, entity_persistor)
    initialize_logger("INFO")
    @evp = event_persistor
    @enp = entity_persistor
  end

  def dispatch(payload)
    @logger.debug "NEW payload"
    @logger.debug payload.inspect

    payload = Events::Payload.new(payload)

    new_event = @evp.new({
      feed: payload.feed,
      type: payload.type,
      content_digest: payload.content_digest,
      source_data: payload.source_data,
    })

    @logger.debug "NEW event"
    @logger.debug new_event.inspect

    procurer = Entities::Procurer.new(@enp, payload)

    new_entity = procurer.procure
    parent     = procurer.find_parent
    children   = procurer.find_children
    references = procurer.find_references

    Entities::Determinator.new(new_entity).determine
    Entities::Normalizer.new(new_entity).normalize

    Entities::Grouper.new(new_entity)
    .join_family(parent)
    .adopt(children)
    .reference(references)
    .caused_by(new_event)

    @logger.debug "NEW entity"
    @logger.debug new_entity.inspect

    ActiveRecord::Base.transaction do
      new_event.save!
      new_entity.save!
      parent.save!
      children.each {|e| e.save!}
      references.each {|e| e.save!}
    end
  end
end
