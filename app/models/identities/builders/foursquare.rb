module Identities
  module Builders
    class Foursquare < Builder::Protocol

      def run
        credentials
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
          oauth_token: @source_data.fetch(:credentials).fetch(:token)
        )
      end
    end
  end
end
