module Supervisors
  module Services
    class FoursquareVenue < Supervisors::Service
      def boot
        venues_handler.register @brand_name, venue_ids
      end

      private

      def venue_ids
        [ service_config.fetch(:id) ]
      end

      def venues_handler
        Celluloid::Actor[:http_server_foursquare_venues]
      end

    end
  end
end
