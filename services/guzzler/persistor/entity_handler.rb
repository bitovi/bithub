require 'handler'

module Guzzler::Persistor

  class EntityHandler < Handler

    def process(packet)
      packet = JSON.parse(packet)

      tenant_name = packet.fetch('tenant_name')
      event_id    = packet.fetch('event_id')

      handle_errors do
        Apartment::Tenant.switch(tenant_name) do
          event = Event.find(event_id)
          if event.is_processed
            Guzzler.logger.warn "[#{name_for_logs}] Event already processed"
          else
            run_pipeline(event)
          end
        end
      end

      @manager.async.worker_done(current_actor)

    rescue Guzzler::HandlingError => e
      Guzzler.zadd('entity_retries_q', Time.now.to_f, {
        tenant_name: tenant_name,
        event_id: event_id, retry_num: 0
      })
      @manager.async.worker_done(current_actor)
    end
    
    def run_pipeline(event)
      entity = Entities.entity_instance(event.wrapped)

      entity_processing_time = Benchmark.measure do
        entity.procure.update_if_found.group.normalize.persist!.route
      end
      
      event.update_attribute(:is_processed, true)

      Guzzler.logger.info "[#{name_for_logs}][#{entity.repr_for_logs}] processed in #{entity_processing_time}"
      entity
    ensure
      event.update_attribute(:was_viewed, true)
    end

  end
end
