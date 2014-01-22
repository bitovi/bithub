require 'andand'
require 'lib/core_ext'
require 'lib/core_helpers'
require 'lib/loggable'

require 'events/dispatcher'
require 'entities/dispatcher'

class Dispatcher
  include Loggable

  def initialize
    initialize_logger("DEBUG")
  end

  def dispatch(response)
    event = Events::Dispatcher.dispatch(response)
    entity = Entities::Dispatcher.dispatch(event)


    @logger.info "Event : #{event.class.name}"
    @logger.debug "Entity : #{entity.class.name}"

    entity.procure.determine.group.normalize.persist

    # ActiveRecord::Base.transaction do
    #   new_event.save!
    #   new_entity.save!
    #   parent.save!
    #   children.each {|e| e.save!}
    #   references.each {|e| e.save!}
    # end
  end
end
