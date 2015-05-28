require 'handlers/handler'

class EventHandler < Handler
  def handle(packet)
    b_id, _, _= destruct(packet)
    Celluloid.logger.info "[EVENT_LISTENER][#{meta_to_log_format(packet)}] New Event received"

    @listener.handle_errors do
      Apartment::Tenant.switch(Brand.find(b_id).name) do
        time = Benchmark.measure do
          Dispatcher.new(logger: Celluloid.logger).dispatch(packet)
        end

        Celluloid.logger.info "Total dispatching time: #{time}"
      end
    end
  end

  def destruct(packet)
    meta = packet.fetch('meta')
    [ meta.fetch('brand_id'), meta.fetch('embed_id'), meta.fetch('service_id')]
  end
end
