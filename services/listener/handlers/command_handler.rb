require 'handlers/handler'

class CommandHandler < Handler
  def handle(packet)
    b_id, s_id = destruct(packet)
    Celluloid.logger.info "[#{meta_to_log_format(packet)}][COMMAND_LISTENER] New command received: #{packet.fetch('payload')}"

    @listener.handle_errors do
      Apartment::Tenant.switch(Brand.find(b_id).name) do
        ServiceError.where(service_id: s_id).destroy_all
      end
    end
  end

  def destruct(packet)
    meta = packet.fetch('meta')
    [ meta.fetch('brand_id'), meta.fetch('service_id')]
  end
end
