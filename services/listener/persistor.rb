require 'entities/entities'
require 'services/intervals'

class Persistor
  include Celluloid
  include Celluloid::Logger
  
  def initialize
    @events_processed = 0
    every(Intervals::Persistor::REPORT) do
      info "[#{name_for_logs}] Processed #{@events_processed} in the last #{Intervals::Persistor::REPORT} seconds"
      @events_processed = 0
    end

    info "[#{name_for_logs}] Started, checking for work every #{Intervals::Persistor::HEARTBEAT} seconds"
    check_for_work
  end

  def check_for_work
    if work_to_be_done?
      bulk_persist
    else
      after(Intervals::Persistor::HEARTBEAT) { check_for_work } 
    end
  end
  
  def work_to_be_done?
    Brand.pluck(:tenant_name).map do |tn|
      Apartment::Tenant.switch(tn) { Event.unprocessed.count }
    end.sum > 0
  end

  def bulk_persist
    Brand.pluck(:tenant_name).each do |tn|
      Apartment::Tenant.switch(tn) do
        Event.unprocessed.order("created_at DESC").limit(50).find_each do |event|
          @events_processed += 1
          process_event(event)
        end
      end
    end

  rescue Entities::DeterminationError => err
    warn "[#{name_for_logs}] #{err} | #{err.context}"
    nil

  rescue ActiveRecord::RecordInvalid => err
    error "[#{name_for_logs}] #{err}"
    nil

  rescue Entities::NormalizationError => err
    error "[#{name_for_logs}] #{err.message} | missing tags: #{err.context.join(',')}"
    nil

  rescue Entities::UpdatingError => err
    error "[#{name_for_logs}] #{err.message} | updating: #{err.context.inspect}"
    nil

  ensure
    Apartment::Tenant.switch!
    after(0) { check_for_work }
  end

  def process_event(event)
    entity = Entities.entity_instance(event.wrapped)

    procurement = nil
    procurement_time = Benchmark.measure do
      procurement = entity.procure.update_if_found
    end

    grouping = nil
    grouping_time = Benchmark.measure do
      grouping = procurement.group
    end

    normalization = grouping.normalize

    persistance = nil
    persistance_time = Benchmark.measure do
      persistance = normalization.persist!
    end

    routing_time = Benchmark.measure do
      persistance.route
    end

    info "[#{name_for_logs}][PROCUREMENT] for entity #{entity.repr_for_logs} completed in #{procurement_time}"
    info "[#{name_for_logs}][GROUPING] for entity #{entity.repr_for_logs} completed in #{grouping_time}"
    info "[#{name_for_logs}][PERSISTANCE] for entity #{entity.repr_for_logs} completed in #{persistance_time}"
    info "[#{name_for_logs}][ROUTING] for entity #{entity.repr_for_logs} completed in #{routing_time}"

    event.update_attribute(:is_processed, true)

  ensure
    event.update_attribute(:was_viewed, true)
  end

  def name_for_logs
    "PERSISTOR"
  end
end
