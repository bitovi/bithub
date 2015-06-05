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
        Celluloid.logger.info "TODO log that something happened?"

        payload = JSON.parse req.body.to_s

        payload.each do |notif|
          object       = notif['object']
          object_id    = notif['object_id']
          method_name  = "handle_postback_#{object}".to_sym

          if self.respond_to? method_name, true
            subscriptions = @proxy.registry['instagram', 'media', object_id]

            if subscriptions.empty?
              Celluloid.logger.info "Unsubscribing from Instagram service for #{object} #{object_id}"
              unsubscribe notif['subscription_id']
            else
              subscriptions.each do |owner_data|
                access_token = owner_data.service.config[:access_token]

                handle_errors(owner_data) do
                  results = self.send method_name.to_sym, object_id, access_token
                  @proxy.publish results, owner_data
                end
              end
            end

          end
        end

        [200, 'OK']
      end

      def unsubscribe(subscription_id)
        client = ::Instagram.client client_id: ENV['INSTAGRAM_CLIENT_ID'], client_secret: ENV['INSTAGRAM_CLIENT_SECRET']
        client.delete_subscription subscription_id
      rescue ::Instagram::BadRequest => e
        Celluloid.logger.info "Unsubscribing from Instagram service failed with #{e}"
      end

      def handle_errors(owner_data)
        yield
      rescue => e
        @proxy.publish_error e, owner_data
      end

      # Subhandlers

      def handle_postback_user(object_id, access_token)
        Fetchers::Instagram::UserRecentMedia.fetch object_id, count: 1, access_token: access_token
      end

      def handle_postback_tag(object_id, access_token)
        Fetchers::Instagram::TagRecentMedia.fetch object_id, count: 1, access_token: access_token
      end

      def handle_postback_location(object_id, access_token)
        Fetchers::Instagram::LocationRecentMedia.fetch object_id, count: 1, access_token: access_token
      end

      def handle_postback_geography(object_id, access_token)
        Fetchers::Instagram::LocationRecentMedia.fetch object_id, count: 1, access_token: access_token
      end

    end

  end
end
