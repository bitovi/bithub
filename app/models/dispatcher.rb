require 'andand'
require 'core_ext'
require 'core_helpers'
require 'logger_factory'

require_relative 'events/dispatcher'
require_relative 'entities/dispatcher'

class Dispatcher

  def initialize(args={})
    @logger = args.fetch(:logger)
  end

  def dispatch(response, hint=nil)
    event = Events::Dispatcher.dispatch(response, hint)
    entity = Entities::Dispatcher.dispatch(event)

    ActiveRecord::Base.transaction do
      event_time = Benchmark.measure do
        event.build.normalize.validate.persist!
      end

      until_validation = nil
      until_validation_time = Benchmark.measure do
        until_validation = entity.procure.update_if_found
      end
        
      validation = nil
      validation_time = Benchmark.measure do
        validation = until_validation.validate
      end
      
      determination = nil
      determination_time = Benchmark.measure do
        determination = validation.determine
      end
        
      grouping = nil
      grouping_time = Benchmark.measure do
        grouping = determination.group
      end
        
      normalization =  nil
      normalization_time = Benchmark.measure do
        normalization = grouping.normalize
      end

      persistance = nil
      persistance_time = Benchmark.measure do
        normalization.persist!.route
      end

      Celluloid.logger.info "------- #{event.feed_name} --------- #{event.type_name} -------"
      Celluloid.logger.info "event dispatching took: #{event_time}"
      Celluloid.logger.info "until_validation dispatching took: #{until_validation_time}"
      Celluloid.logger.info "validation dispatching took: #{validation_time}"
      Celluloid.logger.info "determination dispatching took: #{determination_time}"
      Celluloid.logger.info "grouping dispatching took: #{grouping_time}"
      Celluloid.logger.info "normalization dispatching took: #{normalization_time}"
      Celluloid.logger.info "persistance dispatching took: #{persistance_time}"
    end

    [event.instance, entity.instance]
  rescue Events::OrphanedEventError => err
    @logger.error err
    nil
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
