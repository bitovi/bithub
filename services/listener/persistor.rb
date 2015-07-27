require 'entities/entities'
require 'services/intervals'

class Persistor
  include Celluloid
  include Celluloid::Logger
  
  def initialize(q_name, q_routing_key)
    rf = RabbitHelper.new(ConnectionManager.instance.rabbit)
    @c = rf.chan
    @x = rf.x('x.web')
    @q = rf.q(q_name).bind(@x, routing_key: q_routing_key)

    info "[#{name_for_logs}] Started, checking for work every #{Intervals::Persistor::HEARTBEAT} seconds"
    subscribe
  end

  def subscribe
    @q.subscribe(block: false) do |delivery_info, properties, payload|
      packet = JSON.parse(payload, symbolize_names: true)
      tenant_name = packet.fetch(:tenant_name)

      if event_id = packet[:event_id]
        process_one(tenant_name, event_id)
      else
        process_many(tenant_name)
      end
    end
  end

  def process_one(tenant_name, event_id)
    handle_errors do
      Apartment::Tenant.switch(tenant_name) do
        event = Event.find(event_id)
        if event.is_processed
          warn "[#{name_for_logs}] Event already processed"
        else
          run_pipeline_with_benchmarks(event)
        end
      end
    end
  end

  # Not used currently, but may be used in the future
  # when there is a lot of backpressure on the entities queue
  def process_many(tenant_name)
    handle_errors do
      Apartment::Tenant.switch(tenant_name) do
        Event.unprocessed.order("created_at DESC").limit(500).find_each do |event|
          run_pipeline_with_benchmarks(event)
        end
      end
    end
  end

  def handle_errors
    yield

  rescue ActiveRecord::RecordNotFound => e
    error "[#{name_for_logs}] #{err}"
    nil

  rescue ActiveRecord::RecordInvalid => err
    error "[#{name_for_logs}] #{err}"
    nil

  rescue Entities::DeterminationError => err
    warn "[#{name_for_logs}] #{err} | #{err.context}"
    nil

  rescue Entities::NormalizationError => err
    error "[#{name_for_logs}] #{err.message} | missing tags: #{err.context.join(',')}"
    nil

  rescue Entities::UpdatingError => err
    error "[#{name_for_logs}] #{err.message} | updating: #{err.context.inspect}"
    nil

  ensure
    Apartment::Tenant.switch!
  end

  def run_pipeline_with_benchmarks(event)
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
    entity
  ensure
    event.update_attribute(:was_viewed, true)
  end

  def name_for_logs
    "PERSISTOR"
  end
end
