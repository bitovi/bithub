require 'handler'

module Guzzler::Handlers

  class ErrorHandler < Guzzler::Handler
    def handle(raw_data)
      super do |packet|
        tenant_name = packet.fetch('meta').fetch('tenant_name')
        service_id = packet.fetch('meta').fetch('service_id')
        error = packet.fetch('data').merge(service_id)

        Apartment::Tenant.switch(tenant_name) do
          se = ServiceError.create!(error)
          Notifier.notify_client(:service_error_raised, { service_error: se })
        end
      end

      @popper.ready

    ensure
      Apartment::Tenant.switch!
    end
    # Guzzler.logger.info "[ERROR_LISTENER][#{meta_to_log_format(packet)}] New error received: #{err_klass}"
  end
end
