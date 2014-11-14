module Supervisors::Services
  class Foursquare < Supervisors::Service
    def boot
      venues_handler.register @brand_name, venue_ids
    end

    private

    def venues
      service_config.fetch(:venues)
    end

    def venue_ids
      venues.map {|v| v.fetch(:id)}
    end

    def venues_handler
      Celluloid::Actor[:http_server_foursquare_venues]
    end

  end
end
