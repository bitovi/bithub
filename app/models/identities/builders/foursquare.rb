module Identities
  module Builders
    class Foursquare < Builder::Protocol

      def run
        venues
        self
      end

      def venues
        if vs = venues_over_http
          @storage[:venues] = vs
        end
      end

      private
      def venues_over_http
        client.managed_venues.items
      end

      def client
        Foursquare2::Client.new(
          api_version: '20141111',
          oauth_token: token
        )
      end

    end
  end
end
