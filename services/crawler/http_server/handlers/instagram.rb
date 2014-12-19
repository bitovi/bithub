require 'supervisors/support/brand_info'
require 'supervisors/support/embed_info'
require 'supervisors/support/service_info'

module HttpServer
  module Handlers

    class Instagram
      include Celluloid

      OwnerData = Struct.new :brand, :embed, :service

      def initialize
        Celluloid.logger.info "Started HTTP handler for Instagram"
        @channels = {}
      end

      def handle(req)
        # http://instagram.com/developer/realtime/
        # Instagram makes GET request to verify subscription
        # After that step notifications are sent by POST

        req.method == 'GET' ? handle_subscription(req) : handle_postback(req)
      end

      def handle_subscription(req)
        params =  CGI::parse req.query_string

        [200, params["hub.challenge"].first]
      end

      def handle_postback(req)
        owner_data = build_owner_data_from_url req.url
        payload = JSON.parse req.body.to_s

        payload.each do |notif|
          if object_id = notif['object_id']
            media = Fetchers::Instagram::Media.fetch object_id
            publish owner_data, media.to_h
          end
        end

        # TODO: yield this before making media request!
        [200, 'OK']
      end

      def build_owner_data_from_url(url)
        captures = Regexp.new(self.class.path).match(url)

        owner_data = OwnerData.new\
          BrandInfo.new(captures[:brand_id], captures[:brand_name]),
          EmbedInfo.new(captures[:embed_id], captures[:embed_name]),
          ServiceInfo.new(captures[:service_id], 'instagram', 'media_event')
      end

      def publish(owner_data, body)
        Actor[:publisher].publish owner_data, [body]
      end

      def self.path
        "/instagram/media/(?<brand_id>\\d+)-(?<brand_name>.*)/(?<embed_id>\\d+)-(?<embed_name>.*)/(?<service_id>\\d+)"
      end

    end

  end
end
