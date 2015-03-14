require 'handlers/handler'

class CommandHandler < Handler
  def handle(packet)
    bn, sid = destruct(packet)
    Celluloid.logger.info "New COMMAND received: #{packet.fetch('payload')}, brand: '#{bn}'"

    @listener.handle_errors do
      Apartment::Tenant.switch(bn) do
        ServiceError.where(service_id: sid).destroy_all
      end
    end
  end

  def destruct(packet)
    [ packet.fetch('meta').fetch('brand_name'), packet.fetch('payload').fetch('service').fetch('id') ]
  end
end
