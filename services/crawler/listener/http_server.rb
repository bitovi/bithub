require 'reel'
require_relative 'router'
require_relative 'handler_proxy'
require_relative 'handlers/all'
require_relative 'support/facebook_app_subscriber'

class HttpServer < Reel::Server::HTTP
  include Celluloid::Logger

  attr_reader :routes

  def initialize(args={})
    host        = args[:host]        || ENV['CRAWLER_HTTP_HOST']   || '127.0.0.1'
    port        = args[:port]        || ENV['CRAWLER_HTTP_PORT']   || '3001'
    path_prefix = args[:path_prefix] || ENV['CRAWLER_HTTP_PREFIX'] || '/'

    @publisher_name    = args[:event_publisher_name]       || :event_publisher
    @publisher_name    = args[:error_publisher_name]       || :error_publisher
    @configurator_name = args[:configurator_name]          || :configurator
    @registry_name     = args[:subscription_registry_name] || :subscription_registry

    @handlers  = SupervisionGroup.new
    @router    = Router.new prefix: path_prefix

    super(host, port, &method(:on_connection))
    info "HTTP server listening on #{host}:#{port}"

    boot
  end

  private

  def boot
    @handlers.supervise_as :instagram_subscriptions_handler, HandlerProxy, *[::Handlers::Instagram::Subscriptions]
    @handlers.supervise_as :instagram_notifications_handler, HandlerProxy, *[::Handlers::Instagram::Notifications]
    @handlers.supervise_as :facebook_subscriptions_handler, HandlerProxy, *[::Handlers::Facebook::Subscriptions]
    @handlers.supervise_as :facebook_notifications_handler, HandlerProxy, *[::Handlers::Facebook::Notifications]
    @handlers.supervise_as :foursquare_handler, HandlerProxy, *[::Handlers::Foursquare]

    register_route :instagram_subscriptions_handler, ::Handlers::Instagram::Subscriptions.route
    register_route :instagram_notifications_handler, ::Handlers::Instagram::Notifications.route
    register_route :facebook_subscriptions_handler,  ::Handlers::Facebook::Subscriptions.route
    register_route :facebook_notifications_handler,  ::Handlers::Facebook::Notifications.route
    register_route :foursquare_handler,              ::Handlers::Foursquare.route

    after(5) do
      FacebookAppSubscriber.new.subscribe unless ENV['ENV'] == 'development'
    end
  end

  def on_connection(connection)
    connection.each_request do |req|
      info "#{req.method} #{req.path}"
      route req
    end
  end

  def register_route(handler, route)
    method, path = *route
    @router.register handler, path, method
  end

  def route(req)
    if handler_name = @router.route(req.path, req.method)
      status, msg = Actor[handler_name].handle req
    else
      status, msg = :ok, 'nothing to do'
    end

    req.respond status, msg
  end

end
