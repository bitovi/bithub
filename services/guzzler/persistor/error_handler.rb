require 'handler'

module Guzzler::Persistor

  class ErrorHandler < Handler

    def handle(packet)
      tenant_name = packet.fetch('meta').fetch('tenant_name')
      service_id = packet.fetch('meta').fetch('service_id')
      error = packet.fetch('data').merge(service_id)

      handle_errors do
        Apartment::Tenant.switch(tenant_name) do
          se = ServiceError.create!(error)
          Notifier.notify_client(:service_error_raised, { service_error: se })
        end
      end

      @manager.async.worker_done(current_actor)

    rescue Guzzler::HandlingError => e
      @manager.async.worker_done(current_actor)
    end
  end
end
