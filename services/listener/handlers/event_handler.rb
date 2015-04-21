require 'handlers/handler'

class EventHandler < Handler
  def handle(packet)
    bn, en, fn, tn = destruct(packet)
    Celluloid.logger.info "#{meta_to_log_format(packet)} New Event received"

    @listener.handle_errors do
      Apartment::Tenant.switch(bn) do
        Dispatcher.new(logger: Celluloid.logger).dispatch(packet)
      end
    end
  end

  def destruct(packet)
    meta = packet.fetch('meta')
    [ meta.fetch('brand_name'), meta.fetch('embed_name'), meta.fetch('feed_name'), meta.fetch('type_name') ]
  end
end
