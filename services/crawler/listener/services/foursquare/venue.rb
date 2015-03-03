module Supervisors::Services::Foursquare
  class Venue < Supervisors::Service

    def initialize(path, service_info)
      super
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

    def owner_data
      OwnerData.new\
        @path.brand.id,
        @path.brand.name,
        @path.embed.id,
        @path.embed.name,
        @path.service.id,
        'foursquare',
        'venue'
    end

  end
end
