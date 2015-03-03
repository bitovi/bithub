require 'instagram'
require 'active_support/core_ext/string'

module Supervisors::Services::Instagram
  class Base < Supervisors::Service

    VALID_OBJECTS = %w(user tag location geography)

    def initialize(path, service_info)
      super

      begin
        subscribe service_config
        register_to_handler
      rescue ::Instagram::Error => e
        info "Instagram subscription failed with #{e.message}"
      end

      if self.respond_to? :preloaded_items, true
        publish preloaded_items(service_config), owner_data
      end
    end

    def cleanup
      unregister_from_handler
    end

    private

    def subscribe; raise NotImplementedError; end
    def preloaded_items; raise NotImplementedError; end

    def registry
      Actor[:subscription_registry]
    end

    def register_to_handler
      registry.subscribe 'instagram', 'media', instagram_object_id, owner_data
    end

    def unregister_from_handler
      registry.unsubscribe 'instagram', 'media', instagram_object_id, owner_data
    end

    def instagram_object_id
      service_config[:tag] || service_config[:id]
    end

    def publish(events, owner_data)
      Actor[:event_publisher].publish events, owner_data
    end

    def owner_data
      OwnerData.new\
        @path.brand.id,
        @path.brand.name,
        @path.embed.id,
        @path.embed.name,
        @path.service.id,
        'instagram',
        'media_event'
    end

    def client
      @client ||= ::Instagram.client client_id: ENV['INSTAGRAM_CLIENT_ID'], client_secret: ENV['INSTAGRAM_CLIENT_SECRET']
    end

    def callback_url(opts={})
      domain = opts[:domain] || ENV['CRAWLER_HTTP_DOMAIN']
      port   = opts[:port]   || ENV['CRAWLER_HTTP_PORT']
      path   = File.join ENV['CRAWLER_HTTP_PREFIX'], 'instagram', 'media'

      "http://#{domain}:#{port}#{path}"
    end

  end
end
