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

  def dispatch(response, hint=nil)
    event = Events::Dispatcher.dispatch(response, hint)
    entity = Entities::Dispatcher.dispatch(event)

    @logger.info "Mapping: #{event.class.name} -> #{entity.class.name}"

    ActiveRecord::Base.transaction do
      event.build.persist!
      entity.procure.update_if_found.determine.group.normalize.persist!
    end

    [event.instance, entity.instance]
  rescue Events::MappingError => err
    @logger.error "#{err.message} | #{err.context}"
    nil
  rescue Entities::MappingError => err
    @logger.error "#{err.message} | #{err.context}"
    nil
  rescue Events::BuildingError => err
    @logger.error "#{err.message} | event type: #{err.context.inspect}"
    [event.andand.instance, entity.andand.instance]
  rescue Entities::NormalizationError => err
    @logger.error "#{err.message} | missing tags: #{err.context.join(',')}"
    [event.andand.instance, entity.andand.instance]
  rescue Entities::UpdatingError => err
    @logger.error "#{err.message} | updating: #{err.context.inspect}"
    [event.andand.instance, entity.andand.instance]
  rescue ActiveRecord::RecordInvalid => err
    @logger.error "#{err.message} | #{err.record.errors.messages}"
    [event.andand.instance, entity.andand.instance]
  end
end
#{event.feed_name}:#{event.type_name} -> #{entity.feed_name}:#{entity.type_name}
