module Identities
  module Builders
    class Foursquare < Base

      def initialize(args)
        super
        @client = client
      end

      def venue_name(venue_id)
        managed_venues.find do |v|
          v['id'].to_s == venue_id.to_s
        end['name']
      end

      def build
        @data[:venues] = managed_venues
        @data
      end

      def suggestions(type=nil)
        venue_ids_and_names
      end

      def credentials(argument = nil)
        { access_token: access_token }
      end

      def access_token
        oauth.fetch(:credentials).fetch(:token)
      end
      
      private

      def venue_ids_and_names
        managed_venues.map do |v|
          {
            id: v['id'],
            name: v['name']
          }
        end
      end

      def managed_venues
        @client.managed_venues.items
      end

      def client
        Foursquare2::Client.new(
          api_version: '20141111',
          oauth_token: access_token)
      end

    end
  end
end
