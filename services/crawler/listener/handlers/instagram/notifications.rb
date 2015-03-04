module Handlers
  module Instagram

    class Notifications

      def initialize(proxy)
        @proxy = proxy
      end

      def handle(req)
        handle_postback req
      end

      def self.route
        ['POST', '/instagram/media']
      end

      private

      def handle_postback(req)
        payload = JSON.parse req.body.to_s

        payload.each do |notif|
          object      = notif['object']
          object_id   = notif['object_id']
          method_name = "handle_postback_#{object}".to_sym

          if self.respond_to? method_name, true
            results = self.send method_name.to_sym, object_id

            if subscriptions = @proxy.registry['instagram', 'media', object_id]
              subscriptions.each do |owner_data|
                @proxy.publish results, owner_data
              end
            end
          end
        end

        [200, 'OK']
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
