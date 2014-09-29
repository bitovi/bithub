require 'instagram'

# String#singularize
require 'active_support/core_ext/string'

module FeedSupervisors
  class Instagram
    include Celluloid

    VALID_OBJECTS = %w(user tag location geography)

    def initialize(brand_name)
      @brand_name = brand_name
      boot
    end

    def boot
      Celluloid.logger.info "Booting Instagram supervisor for #{@brand_name}"

      # cleanup existing subscriptions
      delete_subscriptions

      # make new subscriptions
      config[:subscriptions].andand.each do |key, value|
        object        = key.to_s.singularize
        subscriptions = value

        if VALID_OBJECTS.include? object
          subscriptions.each do |params|
            Celluloid.logger.info "Creating Instagram subscription for #{object}, #{params}"
            self.send "subscribe_#{object}", params
          end
        end
      end

    end

    def config
      Celluloid::Actor[:configurator].feed_config(@brand_name, :instagram)
    end

    def token
      config.fetch(:token)
    end

    def actor_name
      "#{@brand_name}_instagram".to_sym
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
