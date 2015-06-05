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

      procurement = nil
      procurement_time = Benchmark.measure do
        procurement = entity.procure.update_if_found
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

      @logger.info "[DISPATCHER][EVENT_DISPATCHING] for event #{event.repr_for_logs} completed in #{event_time}"
      @logger.info "[DISPATCHER][PROCUREMENT] for entity #{entity.repr_for_logs} completed in #{procurement_time}"
      @logger.info "[DISPATCHER][VALIDATION] for entity #{entity.repr_for_logs} completed in #{validation_time}"
      @logger.info "[DISPATCHER][DETERMINATION] for entity #{entity.repr_for_logs} completed in #{determination_time}"
      @logger.info "[DISPATCHER][GROUPING] for entity #{entity.repr_for_logs} completed in #{grouping_time}"
      @logger.info "[DISPATCHER][NORMALIZATION] for entity #{entity.repr_for_logs} completed in #{normalization_time}"
      @logger.info "[DISPATCHER][PERSISTANCE] for entity #{entity.repr_for_logs} completed in #{persistance_time}"
    end

    [event.instance, entity.instance]
  rescue Events::OrphanedEventError => err
    @logger.error "[DISPATCHER] #{err}"
    nil
  rescue Events::DispatchError => err
    @logger.error "[DISPATCHER] #{err.message} | #{err.context}"
    nil
  rescue Entities::DispatchError => err
    @logger.error "[DISPATCHER] #{err.message} | #{err.context}"
    nil
  rescue Events::ValidationError => err
    @logger.error "[DISPATCHER] #{err.message} | #{err.context}"
    nil
  rescue Events::BuildingError => err
    @logger.error "[DISPATCHER] #{err.message} | event type: #{err.context.inspect}"
    [event.andand.instance, entity.andand.instance]
  rescue Entities::NormalizationError => err
    @logger.error "[DISPATCHER] #{err.message} | missing tags: #{err.context.join(',')}"
    [event.andand.instance, entity.andand.instance]
  rescue Entities::UpdatingError => err
    @logger.error "[DISPATCHER] #{err.message} | updating: #{err.context.inspect}"
    [event.andand.instance, entity.andand.instance]
  rescue ActiveRecord::RecordInvalid => err
    @logger.error "[DISPATCHER] #{err.message} | #{err.record.errors.messages}"
    [event.andand.instance, entity.andand.instance]
  end
end
