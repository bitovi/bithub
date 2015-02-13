require 'reel'
require_relative 'handlers/all'

module HttpServer
  class Listener < Reel::Server::HTTP

    def initialize(args={})
      host = args[:host] || ENV['CRAWLER_HTTP_HOST'] || '127.0.0.1'
      port = args[:port] || ENV['CRAWLER_HTTP_PORT'] || '3001'

      super(host, port, &method(:on_connection))

      @path_prefix = args[:route_prefix] || ENV['CRAWLER_HTTP_PREFIX'] || '/'
      @routes = {}

      Celluloid.logger.info "Started HTTP server on http://#{host}:#{port}"
      boot
    end

    def boot
      @handlers = SupervisionGroup.new

      Handlers.constants.each do |handler_name|
        handler    = HttpServer::Handlers.const_get(handler_name)
        actor_name = build_actor_name(handler_name)

        # make regexps of given paths so that wildchars can work
        path       = Regexp.new File.join(@path_prefix, handler.path)

        # start actor and register route
        @handlers.supervise_as actor_name, handler
        add_route path, actor_name

        Celluloid.logger.info "HTTP handler for #{actor_name.inspect} on #{path}"
      end
    end

    def on_connection(connection)
      connection.each_request do |request|
        Celluloid.logger.info "HTTP Listener: #{request.method} #{request.path}"

        # route request to appropiate handler
        if handler_future = route(request)
          code, msg = handler_future.value
          request.respond code, msg
        else
          request.respond :ok, 'nothing to do'
        end
      end
    end

    private

    def route(req)
      if actor_name = @routes[match_route(req.path)]
        if actor = Celluloid::Actor[actor_name]
          actor.future.handle req
        end
      end
    end

    def match_route(path)
      @routes.keys.select {|r| r.match path}.first
    end

    def add_route(path, actor_name)
      @routes[path] = actor_name
    end

    def remove_route(path)
      @routes.delete path
    end

    def build_actor_name(handler_name)
      "http_server_#{handler_name.to_s.snake_case}".to_sym
    end

  end
end
