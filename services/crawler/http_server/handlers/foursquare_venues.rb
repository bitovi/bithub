require 'cgi'

require 'supervisors/support/supervision_node'
require 'supervisors/support/brand_info'
require 'supervisors/support/embed_info'
require 'supervisors/support/service_info'

module HttpServer
  module Handlers

    class FoursquareVenues
      include Celluloid

      OwnerData = Struct.new :brand, :embed, :service

      def initialize
        Celluloid.logger.info "Started HTTP handler for Foursquare Venues"
        @channels = {}
      end

      def handle(req)
        # FS postback sends data in URL encoded form :/
        parsed  = CGI.parse req.body.to_s

        secret  = parsed['secret'].first
        evtype  = (parsed['checkin'] && 'checkin') ||
                  (parsed['like'] && 'like') ||
                  (parsed['tip'] && 'tip') ||
                  (parsed['photo'] && 'photo')
        payload = parsed[evtype] || []

        # somebody is playing with us, pretend dead
        if secret != ENV['FOURSQUARE_PUSH_SECRET']
          Celluloid.logger.info "[FourSquare handler] unmatched push secret #{secret}"
          return [404, 'Not found']
        end

        payload.each do |event|
          event = JSON.parse event
          @channels.each do |id, routes|
            if id == event.fetch('venue').fetch('id')
              routes.each {|route| publish route, event, evtype}
            end
          end
        end

        [200, 'OK']
      end

      def register(venue_id, path)
        Celluloid.logger.info "Registering channel for Foursquare, venue_id: #{venue_id}, path: #{path}"

        if route = @channels[venue_id]
          route.push path
        else
          @channels[venue_id] = [path]
        end
      end

      def unregister(path)
        @channels.each do |id, routes|
          routes.delete path
        end
      end

      private

      def publish(path, event, event_type)
        _, brand, embed, service = SupervisionNode.deserialize(path)

        # return unless main && brand && embed && service

        owner_data = OwnerData.new\
          BrandInfo.new(brand[:id], brand[:name]),
          EmbedInfo.new(embed[:id], embed[:name]),
          ServiceInfo.new(service[:id], 'foursquare', "#{event_type}_event")

        Celluloid::Actor[:publisher].publish [event], owner_data
      end

      def self.path
        '/foursquare/venues'
      end

    end

  end
end
