module Identities
  module Builders
    class Foursquare < Base

      def initialize(args)
        super
        @conn = create_foursquare_client
        self
      end

      def build
        #sync_venues
        @data
      end

      def sync_venues
        @data[:venues] = fetch_venues
      end

      # Accessors

      def access_token
        oauth.fetch(:credentials).fetch(:token)
      end

      private

      def fetch_venues

      end

      def create_foursquare_client

      end

    end
  end
end
