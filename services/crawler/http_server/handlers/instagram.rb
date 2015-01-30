require 'supervisors/support/owner_data'

module HttpServer
  module Handlers

    class Instagram
      include Celluloid

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
          object          = notif['object']
          object_id       = notif['object_id']
          subscription_id = notif['subscription_id']

          if !owner_exists?(owner_data) && ENV['INSIDE_TEST'] != 'true'
            unsubscribe subscription_id
            next
          end

          method_name = "handle_postback_#{object}".to_sym

          if self.respond_to? method_name, true
            results = self.send method_name.to_sym, object_id

            results.each do |media|
              publisher.publish [media.to_h], owner_data
            end
          end
        end

        # TODO: yield this before making media request!
        [200, 'OK']
      end

      def build_owner_data_from_url(url)
        captures = Regexp.new(self.class.path).match(url)

        OwnerData.new\
          captures[:brand_id],
          captures[:brand_name],
          captures[:embed_id],
          captures[:embed_name],
          captures[:service_id],
          'instagram',
          'media_event'
      end

      def self.path
        "/instagram/media/(?<brand_id>\\d+)-(?<brand_name>.*)/(?<embed_id>\\d+)-(?<embed_name>.*)/(?<service_id>\\d+)"
      end

      private

      def unsubscribe(subscription_id)
          Celluloid.logger.info "Deleting Instagram subscription #{subscription_id}"
          client.delete_subscription subscription_id
      end

      def client
        @client ||= ::Instagram.client client_id: ENV['INSTAGRAM_CLIENT_ID'], client_secret: ENV['INSTAGRAM_CLIENT_SECRET']
      end

      def owner_exists?(owner_data)
        !!Actor[:configurator].service_config(owner_data.brand, owner_data.embed, owner_data.service)
      rescue StandardError
        false
      end

      def publisher
        Actor[:publisher]
      end

      # Subhandlers

      def handle_postback_user(object_id)
        Fetchers::Instagram::UserRecentMedia.fetch object_id, count: 1
      end

      def handle_postback_tag(object_id)
        Fetchers::Instagram::TagRecentMedia.fetch object_id, count: 1
      end

      def handle_postback_location(object_id)
        Fetchers::Instagram::LocationRecentMedia.fetch object_id, count: 1
      end

      def handle_postback_geography(object_id)
        Fetchers::Instagram::LocationRecentMedia.fetch object_id, count: 1
      end
    end

  end
end
