require 'events/events'
require 'handlers/handler'

class EventHandler < Handler
  def initialize(listener)
    super
    @x = @listener.x
  end

  def handle(packet)
    brand_id = packet.fetch('meta').fetch('brand_id')
    tenant_name = Brand.find(brand_id).tenant_name

    Apartment::Tenant.switch(tenant_name) do
      if (event = process_packet(packet))
        @x.publish(JSON.generate({
          tenant_name: tenant_name,
          event_id: event.instance.id
        }), routing_key: 'entities')
      end
    end
  end
  
  def process_packet(packet)
    event = Events.event_instance({
      source_data: packet.fetch('source_data'),
      meta: packet.fetch('meta')
    })
        
    event_processing_time = Benchmark.measure do
      event.build.normalize.validate.persist!
    end

    Celluloid.logger.info "[#{name_for_logs}][#{event.repr_for_logs}] processed in #{event_processing_time}"
    event

  rescue Events::DeterminationError => err
    Celluloid.logger.warn "[#{name_for_logs}] #{err.message} | #{err.context}"
    nil

  rescue ActiveRecord::RecordNotUnique => err
    Celluloid.logger.warn "[#{name_for_logs}][#{event.repr_for_logs}] #{err}"
    nil
  
  rescue Events::OrphanedEventError => err
    Celluloid.logger.warn "[#{name_for_logs}][#{event.repr_for_logs}] #{err.message}"
    nil
  
  rescue Events::BuildingError => err
    Celluloid.logger.error "[#{name_for_logs}][#{event.repr_for_logs}] #{err}"
    nil

  rescue => err
    Celluloid.logger.error "[#{name_for_logs}] #{err}"
    nil

  ensure
    Apartment::Tenant.switch!
  end
end
