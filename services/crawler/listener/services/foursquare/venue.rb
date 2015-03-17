module Supervisors::Services::Foursquare
  class Venue < Supervisors::Service

    def boot
      registry.subscribe 'foursquare', 'venue', venue_id, owner_data
    end

    def cleanup
      registry.unsubscribe 'foursquare', 'venue', venue_id, owner_data
    end

    private

    def venue_id
      service_config.fetch(:id)
    end

    def registry
      Actor[:subscription_registry]
    end

  end
end
