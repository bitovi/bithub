require 'andand'
require 'core_ext'
require 'core_helpers'
require 'loggable'

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

    begin
      ActiveRecord::Base.transaction do
        event.build.persist!
        entity.procure.update_if_found.determine.group.normalize.persist!
      end

    rescue Events::InvalidDigestSeed => err
      @logger.error "#{event.feed_name}:#{event.type_name} -> #{entity.feed_name}:#{entity.type_name} | #{err.message} | #{err.source_data}"
    rescue ActiveRecord::RecordInvalid => err
      @logger.error "#{event.feed_name}:#{event.type_name} -> #{entity.feed_name}:#{entity.type_name} | #{err.message}"
    end

    # [event.instance, entity.instance]
    entity.instance
  end
end
