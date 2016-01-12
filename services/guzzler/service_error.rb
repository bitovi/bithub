module Guzzler
  class ServiceError

    def initialize(error, service)
      @error = error
      @service = service
    end

    def to_h
      {
        data: {
          klass: @error.class.name,
          message: @error.message,
          backtrace: @error.backtrace.join("\n")
          # happened_at: Time.now.to_f
        },
        meta: {
          tenant_name: @service.tenant_name,
          service_id: @service.service_id
        }
      }
    end
  end
end
