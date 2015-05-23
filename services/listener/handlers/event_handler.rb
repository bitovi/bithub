require 'handlers/handler'

class EventHandler < Handler
  def handle(packet)
    b_id, _, _= destruct(packet)
    Celluloid.logger.info "[#{meta_to_log_format(packet)}][EVENT_LISTENER] New Event received"

    @listener.handle_errors do
      Apartment::Tenant.switch(Brand.find(b_id).name) do
        Dispatcher.new(logger: Celluloid.logger).dispatch(packet)
      end
    end
  end

  def destruct(packet)
    meta = packet.fetch('meta')
    [ meta.fetch('brand_id'), meta.fetch('embed_id'), meta.fetch('service_id')]
  end
end
