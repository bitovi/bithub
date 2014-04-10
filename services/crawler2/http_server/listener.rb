require 'reel'
require_relative 'handlers/all'

module HttpServer
  class Listener < Reel::Server::HTTP

    def initialize(host = "127.0.0.1", port = 3000)
      super(host, port, &method(:on_connection))

      @routes = {}
      Celluloid.logger.info "Started HTTP server on http://#{host}:#{port}"
      boot
    end

    def boot
      @handlers = SupervisionGroup.new

      Handlers.constants.each do |handler_name|
        handler = HttpServer::Handlers.const_get(handler_name)
        actor_name = build_actor_name(handler_name)

        # start actor and register route
        @handlers.supervise_as actor_name, handler
        add_route handler.route, actor_name

        Celluloid.logger.info "HTTP handler for #{actor_name.inspect} on #{handler.route}"
      end
    end

    def on_connection(connection)
      connection.each_request do |request|
        Celluloid.logger.info "HTTP Listener: #{request.method} #{request.path}"

        # route request to appropiate handler
        route request

        # always respond with 200
        request.respond :ok, "OK"
      end
    end

    private

    def route(req)
      if actor_name = @routes[req.path]
        if actor = Celluloid::Actor[actor_name]
          actor.handle req.body
        end
      end
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
