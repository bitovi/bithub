require 'instagram'
require 'active_support/core_ext/string'

module Guzzler
  module Listener
    module Subscribers
      class InstagramBase < BaseSubscriber

        VALID_OBJECTS = %w(user tag location geography)

        def subscribe
          create_subscription
          @registry.subscribe 'instagram', 'media', instagram_object_id, @service
        rescue ::Instagram::Error => e
          raise Guzzler::SubscriptionError.new(e)
        end

        def unsubscribe
          delete_subscription
          @registry.unsubscribe 'instagram', 'media', instagram_object_id, @service
        rescue ::Instagram::Error => e
          raise Guzzler::SubscriptionError.new(e)
        end

        private
        def instagram_object_id
          @service.config[:tag] || @service.config[:id]
        end

        def client
          @client ||= ::Instagram.client client_id: ENV['INSTAGRAM_CLIENT_ID'], client_secret: ENV['INSTAGRAM_CLIENT_SECRET']
        end

        def callback_url
          # Tunnel is used only in development (b/c Instagram can't connect to your local dev machine directly)
          domain =  (ENV['ENV'] == 'development') ? ENV['TUNNEL_GUZZLER_HOST'] : ENV['GUZZLER_HTTP_DOMAIN']
          port   =  (ENV['ENV'] == 'development') ? ENV['TUNNEL_GUZZLER_PORT'] : ENV['GUZZLER_PORT'] 

          path   = File.join(ENV['GUZZLER_POSTBACK_ENDPOINT_PREFIX'] || '/', 'instagram', 'media')

          (port == 80) ? "http://#{domain}#{path}" : "http://#{domain}:#{port}#{path}"
        end
      end

      class InstagramGeography < InstagramBase
        def create_subscription
          lat    = @service.config.fetch(:lat)
          lng    = @service.config.fetch(:lng)
          radius = @service.config.fetch(:radius)

          client.create_subscription object: "geography", callback_url: callback_url, aspect: "media", lat: lat, lng: lng, radius: radius
        end

        def delete_subscription
          #client.delete_subscription subscription_id
        end

        # Implement later b/c --> http://instagram.com/developer/endpoints/geographies/
        # def preload(params)
        #   Fetchers::Instagram::GeographyRecentMedia.fetch params.fetch(:id), count: 100
        # end
      end

      class InstagramLocation < InstagramBase
        def create_subscription
          client.create_subscription object: "location", callback_url: callback_url, aspect: "media", object_id: @service.config.fetch(:location_id)
        end

        def delete_subscription
          # client.delete_subscription subscription_id
        end

        def preload_items
          Fetchers::Instagram::LocationRecentMedia.fetch @service.config.fetch(:id), count: 100
        end
      end

      class InstagramTag < InstagramBase
        def create_subscription
          client.create_subscription object: "tag", callback_url: callback_url, aspect: "media", object_id: @service.config.fetch(:tag)
        end

        def delete_subscription
          # client.delete_subscription subscription_id
        end

        def preload_items
          Fetchers::Instagram::TagRecentMedia.fetch @service.config.fetch(:tag), count: 100
        end
      end

      class InstagramUser < InstagramBase
        def create_subscription
          client.create_subscription object: "user", callback_url: callback_url, aspect: "media"
        end

        def delete_subscription
          # client.delete_subscription subscription_id
        end

        def preload_items
          Fetchers::Instagram::UserRecentMedia.fetch @service.config.fetch(:id), count: 100
        end
      end
    end
  end
end
