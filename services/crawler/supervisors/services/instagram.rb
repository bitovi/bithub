require 'instagram'
require 'active_support/core_ext/string'

module Supervisors
  module Services
    class Instagram < Supervisors::Service
      VALID_OBJECTS = %w(user tag location geography)

      def boot
        # cleanup existing subscriptions
        delete_subscriptions

        # make new subscriptions
        config[:subscriptions].andand.each do |key, value|
          object        = key.to_s.singularize
          subscriptions = value

          if VALID_OBJECTS.include? object
            subscriptions.each do |params|
              Celluloid.logger.info "Creating Instagram subscription for #{object}, #{params}"

              begin
                self.send "subscribe_#{object}", params
              rescue ::Instagram::Error => e
                Celluloid.logger.info "Instagram subscription failed for #{object}, #{params} with #{e.message}"
              end
            end
          end
        end

      end

      def token
        service_config.fetch(:token)
      end

      private

      def delete_subscriptions
        client.subscriptions.each do |sub|
          Celluloid.logger.info "Deleting Instagram subscription #{sub.id}"
          client.delete_subscription sub.id
        end
      end

      def subscribe_user(params=nil)
        client.create_subscription object: "user", callback_url: callback_url, aspect: "media"
      end

      def subscribe_tag(object_id)
        client.create_subscription object: "tag", callback_url: callback_url, aspect: "media", object_id: object_id
      end

      def subscribe_location(location_id)
        client.create_subscription object: "location", callback_url: callback_url, aspect: "media", object_id: location_id
      end

      def subscribe_geography(opts)
        lat    = opts.fetch(:lat)
        lng    = opts.fetch(:lng)
        radius = opts.fetch(:radius)

        client.create_subscription object: "geography", callback_url: callback_url, aspect: "media", lat: lat, lng: lng, radius: radius
      end

      def client
        @client ||= ::Instagram.client client_id: ENV['INSTAGRAM_CLIENT_ID'], client_secret: ENV['INSTAGRAM_CLIENT_SECRET']
      end

      def callback_url(opts={})
        domain = opts[:domain] || 'bithub.com'
        port   = opts[:port] || 9123
        path   = File.join ENV['CRAWLER_HTTP_PREFIX'], 'instagram', 'media', @brand_name.to_s

        "http://#{domain}:#{port}#{path}"
      end

    end
  end
end
