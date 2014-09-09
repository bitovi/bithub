require 'cgi'

module HttpServer
  module Handlers

    class FoursquareVenues
      include Celluloid

      def initialize
        Celluloid.logger.info "Started HTTP handler for Foursquare Venues"
        @channels = {}
      end

      def handle(body)
        parsed  = CGI.parse body.to_s
        secret  = parsed['secret']
        payload = parsed['checkin'] || parsed['like'] || parsed['tip'] || []

        if payload = payload.first
          payload = JSON.parse payload

          @channels.each do |brand, ids|
            publish brand, payload if ids.include? venue_id(payload)
          end
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
