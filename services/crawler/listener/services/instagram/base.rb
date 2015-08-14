require 'instagram'
require 'active_support/core_ext/string'

module Supervisors::Services::Instagram
  class Base < Supervisors::Service

    VALID_OBJECTS = %w(user tag location geography)

    def boot
      begin
        subscribe service_config
        register_to_handler
      rescue ::Instagram::Error => e
        info "Instagram subscription failed with #{e.message}"
        error e
      end

      preload
    end

    def cleanup
      unregister_from_handler
    end

    private

    def subscribe; raise NotImplementedError; end
    def preloaded_items; raise NotImplementedError; end

    def preload
      if self.respond_to? :preloaded_items, true
        handle_errors do
          result = preloaded_items service_config
          if result.empty?
            notify_frontend owner_data
          else
            publish result, owner_data
          end
        end
      end
    end

    def handle_errors
      yield
    rescue => e
      Actor[:error_publisher].publish e, owner_data
    end

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

    # todo: unify with poller
    def notify_frontend(owner_data)
      notif = { payload: { service: { id: owner_data.service.id, empty_results: true } } }
      Actor[:notification_publisher].publish_to_frontend(notif, owner_data)
    end

    def client
      @client ||= ::Instagram.client client_id: ENV['INSTAGRAM_CLIENT_ID'], client_secret: ENV['INSTAGRAM_CLIENT_SECRET']
    end

    def callback_url(opts={})
      # Tunnel is used only in development (b/c Instagram can't connect to your local dev machine directly)
      domain =  ENV['TUNNEL_CRAWLER_HOST'] || opts[:domain] || ENV['LOCAL_CRAWLER_HOST']
      port   =  ENV['TUNNEL_CRAWLER_PORT'] || opts[:port]   || ENV['LOCAL_CRAWLER_PORT'] 

      path   = File.join ENV['CRAWLER_HTTP_PREFIX'], 'instagram', 'media'

      if port == '80'
        "http://#{domain}#{path}"
      else
        "http://#{domain}:#{port}#{path}"
      end
    end
  end
end
