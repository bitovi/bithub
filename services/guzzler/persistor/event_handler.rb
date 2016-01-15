require 'handler'

module Guzzler::Persistor

  class EventHandler < Handler

    def process(packet)
      packet = JSON.parse(packet)

      tenant_name = packet.fetch('meta').fetch('tenant_name')
      source_data = packet.fetch('data')

      handle_errors do
        Apartment::Tenant.switch(tenant_name) do
          if event = process_and_persist_packet(packet)
            Guzzler.lpush('entity_q', {
              tenant_name: tenant_name,
              event_id: event.instance.id
            })
          end
        end
      end

      @manager.async.worker_done(current_actor)

    rescue Guzzler::HandlingError => e
      @manager.async.worker_done(current_actor)
    end

    def process_and_persist_packet(packet)
      event = Events.event_instance({
        source_data: packet.fetch('data'),
        meta: packet.fetch('meta')
      })

      event_processing_time = Benchmark.measure do
        event.build.normalize.validate.persist!
      end

      Guzzler.logger.info "[#{name_for_logs}][#{event.repr_for_logs}] processed in #{event_processing_time}"
      event
    end
  end
end
