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

    # @logger.info "MAPPING, Event : Entity => #{event.class.name} : #{entity.class.name}"

    begin
      ActiveRecord::Base.transaction do
        event.build.persist!
        entity.procure.determine.group.normalize.persist!
      end
    rescue ActiveRecord::RecordInvalid => err
      @logger.error "#{event.feed}:#{event.type} -> #{entity.feed_name}:#{entity.type_name} | #{err.message}"

      # unless err.message == "Validation failed: Content digest has already been taken"
        # @logger.error entity.instance.inspect if event.type_name == "Push" || event.type_name == "push"
      # end
    end
  end
end
