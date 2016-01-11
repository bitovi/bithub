require 'handler'

module Guzzler::Handlers
  class EventHandler < Guzzler::Handler

    def handle(raw_data)
      super do |packet|
        tenant_name = packet.fetch('meta').fetch('tenant_name')
        source_data = packet.fetch('data')

        Apartment::Tenant.switch(tenant_name) do
          if event = process_and_persist_packet(packet)
            Guzzler.lpush('entity_q', {
              tenant_name: tenant_name,
              event_id: event.instance.id
            })
          end
        end
      end

      @popper.ready
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

    rescue Events::DeterminationError => err
      Guzzler.logger.warn "[#{name_for_logs}] #{err.message} | #{err.context}"
      nil

    rescue ActiveRecord::RecordNotUnique => err
      Guzzler.logger.warn "[#{name_for_logs}][#{event.repr_for_logs}] #{err}"
      nil

    rescue Events::OrphanedEventError => err
      Guzzler.logger.warn "[#{name_for_logs}][#{event.repr_for_logs}] #{err.message}"
      nil

    rescue Events::BuildingError => err
      Guzzler.logger.error "[#{name_for_logs}][#{event.repr_for_logs}] #{err}"
      nil

    rescue => err
      Guzzler.logger.error "[#{name_for_logs}] #{err}"
      nil

    ensure
      Apartment::Tenant.switch!
    end
  end
end
