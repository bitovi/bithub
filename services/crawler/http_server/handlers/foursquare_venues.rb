module HttpServer
  module Handlers

    class FoursquareVenues
      include Celluloid

      def initialize
        Celluloid.logger.info "Started HTTP handler for Foursquare Venues"
        @channels = {}
      end

      def handle(body)
        body = JSON.parse(body)

        @channels.each do |brand, ids|
          publish brand, body if ids.include? venue_id(body)
        end
      end

      def register(brand, venue_ids)
        @channels[brand] = venue_ids
      end

      def unregister(brand)
        if channel = @channels[brand]
          @channel.delete brand
        end
      end

      private

      def publish(brand, body)
        Celluloid::Actor[:publisher].publish brand, :foursquare, [body]
      end

      def venue_id(body)
        body.fetch('venue').fetch('id')
      end

      def self.path
        '/foursquare/venues'
      end

    end

  end
end
