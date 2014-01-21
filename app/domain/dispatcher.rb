require 'andand'
require 'lib/core_ext'
require 'lib/core_helpers'
require 'lib/loggable'

require 'events/payload'

require 'entities/mappings'
require 'entities/procurer'
require 'entities/determinator'
require 'entities/grouper'
require 'entities/normalizer'

class Dispatcher
  include Loggable

  def initialize(response)
    initialize_logger("DEBUG")
    @response = response
  end

  def dispatch
    event = Events::Dispatcher.construct_event(@response)
    entity = Entities::Procurer.new(event).procure
    
    @logger.info "Event : #{event.class.name}"
    @logger.debug "Entity : #{entity.class.name}"

    event_record = Event.new({
      feed: event.feed,
      type: event.type,
      content_digest: event.content_digest,
      source_data: event.source_data,
    })

    Entities::Determinator.new(entity).determine
    Entities::Normalizer.new(entity).normalize
    Entities::Grouper.new(entity).group

    # ActiveRecord::Base.transaction do
    #   new_event.save!
    #   new_entity.save!
    #   parent.save!
    #   children.each {|e| e.save!}
    #   references.each {|e| e.save!}
    # end
  end
end
