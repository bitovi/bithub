require 'andand'
require 'core_ext'
require 'core_helpers'
require 'logger_factory'

require_relative 'events/dispatcher'
require_relative 'entities/dispatcher'

class Dispatcher

  def initialize(args={})
    @logger = args[:logger] || LoggerFactory.new('dispatcher', :environment => ENV['ENV']).component_logger
  end

  def dispatch(response, hint=nil)
    event = Events::Dispatcher.dispatch(response, hint)
    entity = Entities::Dispatcher.dispatch(event)

    ActiveRecord::Base.transaction do
      event.build.normalize.validate.persist!
      entity.procure.update_if_found.validate.determine.group.normalize.persist!
    end

    [event.instance, entity.instance]
  rescue Events::DispatchError => err
    @logger.error "#{err.message} | #{err.context}"
    nil
  rescue Entities::DispatchError => err
    @logger.error "#{err.message} | #{err.context}"
    nil
  rescue Events::ValidationError => err
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
