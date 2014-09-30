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
        brand   = brand_from_url req.url
        payload = JSON.parse req.body.to_s

        payload.each do |notif|
          if object_id = notif['object_id']
            media = Fetchers::Instagram::Media.fetch object_id
            publish brand, media.to_h
          end
        end

        # TODO: yield this before making media request!
        [200, 'OK']
      end

      def brand_from_url(url)
        Regexp.new(self.class.path).match(url)[1]
      end

      def publish(brand, body)
        Celluloid::Actor[:publisher].publish brand, :instagram, [body]
      end

      def self.path
        "/instagram/media/(.*)"
      end

    end

  end
end
