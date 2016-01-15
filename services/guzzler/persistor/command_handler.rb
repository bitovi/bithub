require 'handler'

module Guzzler::Persistor

  class CommandHandler < Handler

    def handle(packet)
      tenant_name = packet.fetch('meta').fetch('tenant_name')
      service_id = packet.fetch('meta').fetch('service_id')

      handle_errors do
        Apartment::Tenant.switch(tenant_name) do
          ServiceError.where(service_id: service_id).destroy_all
        end
      end

      @manager.async.worker_done(current_actor)

    rescue HandlingError => e
      @manager.async.worker_done(current_actor)
    end
  end

end
