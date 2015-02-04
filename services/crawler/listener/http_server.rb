require 'reel'
require_relative 'handler_proxy'
require_relative 'handlers/all'

class HttpServer < Reel::Server::HTTP

  attr_reader :routes

  def initialize(args={})
    host = args[:host] || ENV['CRAWLER_HTTP_HOST'] || '127.0.0.1'
    port = args[:port] || ENV['CRAWLER_HTTP_PORT'] || '3001'

    @path_prefix       = args[:path_prefix] || ENV['CRAWLER_HTTP_PREFIX'] || '/'
    @logger            = args[:logger]      || Celluloid.logger
    @publisher_name    = args[:publisher_name] || :publisher
    @configurator_name = args[:configurator_name] || :configurator

    @handlers  = SupervisionGroup.new
    @routes    = {}

    super(host, port, &method(:on_connection))
    @logger.info "HTTP server listening on #{host}:#{port}"

    boot
  end

  private

  def boot
    @handlers.supervise_as :instagram_handler, HandlerProxy, *[@publisher_name, @logger, @configurator_name, Handlers::Instagram]
    # @handlers.supervise_as :facebook_handler,  HandlerProxy, *[@publisher, @logger, @configurator, Handlers::Facebook]
    @handlers.supervise_as :foursquare_handler, HandlerProxy, *[@publisher_name, @logger, @configurator_name, Handlers::Foursquare]

    register_route Handlers::Instagram.path,  Actor[:instagram_handler]
    # register_route Handlers::Facebook.path,   facebook_handler
    register_route Handlers::Foursquare.path, Actor[:foursquare_handler]
  end

  def on_connection(connection)
    connection.each_request do |req|
      @logger.info "#{req.method} #{req.path}"
      route(req)
    end
  end

  def register_route(path, handler)
    route = Regexp.new File.join(@path_prefix, path)
    @routes[route] = handler
  end

  def route(req)
    if path = @routes.keys.select {|r| r.match req.path}.first
      status, msg = @routes[path].handle req
      req.respond status, msg
    else
      req.respond :ok, 'nothing to do'
    end
  end

end
