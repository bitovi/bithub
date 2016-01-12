require 'reel'
require 'koala'

require 'router'
require 'handler'

# require 'support/facebook_app_subscriber'

module Guzzler
  module Listener

    class HttpServer < Reel::Server::HTTP

      def initialize(registry, opts = {})
        @opts = opts
        @registry = registry
        @router = Router.new prefix: path_prefix

        super(host, port, &method(:on_connection))

        Guzzler.logger.info "HTTP server listening on #{host}:#{port}"
    
        # use Facebook v2.2 API
        Koala.config.api_version = 'v2.2'
      end

      def start
        @router.register_handler(
          ['GET', '/instagram/media'],
          Handlers::InstagramSubscriptions.new(@registry))
        
        @router.register_handler(
          ['GET', '/facebook/page/feed'],
          Handlers::FacebookSubscriptions.new(@registry))

        @router.register_handler(
          ['POST', '/instagram/media'],
          Handlers::InstagramNotifications.new(@registry))
        
        @router.register_handler(
          ['POST', '/facebook/page/feed'],
          Handlers::FacebookNotifications.new(@registry))
        
        @router.register_handler(
          ['POST', '/foursquare/venues'],
          Handlers::FacebookNotifications.new(@registry))

        Guzzler.logger.info "Handlers registered"
      end

      private

      def on_connection(connection)
        connection.each_request do |req|
          Guzzler.logger.info "#{req.method} #{req.path}"
          status, msg = route(req)
          req.respond status, msg
        end
      end

      def register_route(handler, route)
        method, path = *route
        @router.register handler, path, method
      end

      def route(req)
        if handler = @router.route(req.path, req.method)
          handler.handle req
        else
          [:ok, 'nothing to do']
        end
      end

      def host
        @opts[:host] || ENV['LOCAL_CRAWLER_HOST'] || '127.0.0.1'
      end

      def port
        @opts[:port] || ENV['LOCAL_CRAWLER_PORT'] || '3001'
      end

      def path_prefix
        @opts[:path_prefix] || ENV['CRAWLER_HTTP_PREFIX'] || '/'
      end
    end
  end
end

# fb_subscription_listener_condvar = Celluloid::Condition.new
# FacebookAppSubscriber.new(fb_subscription_listener_condvar).async.subscribe unless ENV['INSIDE_TEST']
# @facebook_subscriptions_handler  = HandlerProxy.new(Listener::Handlers::FacebookSubscriptions, { :condvar = > fb_subscription_listener_condvar })
# @facebook_notifications_handler  = HandlerProxy.new(Listener::Handlers::FacebookNotifications)
# @foursquare_handler              = HandlerProxy.new(Listener::Handlers::Foursquare)

# register_route :facebook_subscriptions_handler,  ::Handlers::FacebookSubscriptions.route
# register_route :facebook_notifications_handler,  ::Handlers::FacebookNotifications.route
# register_route :foursquare_handler,              ::Handlers::Foursquare.route
