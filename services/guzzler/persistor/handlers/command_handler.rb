module Guzzler::Handlers

  class CommandHandler < Guzzer::Handler
    def handle(raw_data)
      super do |packet|
        tenant_name = packet.fetch('meta').fetch('tenant_name')
        service_id = packet.fetch('meta').fetch('service_id')

        Apartment::Tenant.switch(tenant_name) do
          ServiceError.where(service_id: service_id).destroy_all
        end
      end

      @popper.ready

    ensure
      Apartment::Tenant.switch!
    end
    # Celluloid.logger.info "[COMMAND_LISTENER][#{meta_to_log_format(packet)}] New command received: #{packet.fetch('payload')}"
  end

end
