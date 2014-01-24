require 'andand'
require 'lib/core_ext'
require 'lib/core_helpers'
require 'lib/loggable'

require_relative 'events/dispatcher'
require_relative 'entities/dispatcher'

class Dispatcher
  include Loggable

  def initialize
    initialize_logger("DEBUG")
  end

  def dispatch(response)
    event = Events::Dispatcher.dispatch(response)
    entity = Entities::Dispatcher.dispatch(event)

    @logger.info "MAPPING, Event : Entity => #{event.class.name} : #{entity.class.name}"


    ActiveRecord::Base.transaction do
      event.build.persist!
      entity.procure.determine.group.normalize.persist!
    end

    # ActiveRecord::Base.transaction do
    #   new_event.save!
    #   new_entity.save!
    #   parent.save!
    #   children.each {|e| e.save!}
    #   references.each {|e| e.save!}
    # end
  end
end
