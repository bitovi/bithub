module Guzzler
  module Listener
    module Handlers

      class InstagramSubscriptions < Handler
        def handle(req)
          params = CGI::parse req.query_string
          [200, params['hub.challenge'].first]
        end
      end


      class InstagramNotifications < Handler

        def handle(req)
          super do
            payload = JSON.parse req.body.to_s

            payload.each do |notif|
              object       = notif['object']
              object_id    = notif['object_id']
              method_name  = "handle_postback_#{object}".to_sym

              if self.respond_to? method_name, true
                subscriptions = @registry.fetch('instagram', 'media', object_id)

                if subscriptions.empty?
                  Celluloid.logger.info "Unsubscribing from Instagram service for #{object} #{object_id}"
                  unsubscribe notif['subscription_id']
                else
                  subscriptions.each do |service|
                    results = send method_name.to_sym, object_id, service.config[:access_token]
                    publish results, service
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
          Celluloid.logger.error (msg = "Unsubscribing from Instagram service failed with #{e}")
          raise Guzzler::SubscriptionError.new(msg)
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
end
