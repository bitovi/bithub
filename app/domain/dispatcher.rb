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

  def initialize
    initialize_logger("DEBUG")
  end

  def dispatch(response)
    event = Events::Dispatcher.construct_event(response)
    entity = Entities::Dispatcher.construct_entity(event)
    
    event.build

    @logger.info "Event : #{event.class.name}"
    @logger.debug "Entity : #{entity.class.name}"

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
