require 'guzzler/error'

module Guzzler::Listener
  class Router

    DEFAULT_METHOD = '*'

    def initialize(opts={})
      @routes = {}
    end
    attr_reader :routes
    
    def route(path, method=DEFAULT_METHOD)
      method = build_method method
      @routes[[method,path]] || @routes[[DEFAULT_METHOD, path]]
    end

    def register_handler(route, handler)
      method, path = *route

      method = build_method method
      path   = build_path path

      if @routes[[method,path]]
        fail Guzzler::HandlerAlreadyRegisteredError, "Handler #{handler} already registered for #{method} #{path}."
      else
        @routes[[method,path]] = handler
      end
    end

    def routes
      @routes
    end

    def unregister_handler(path, method=DEFAULT_METHOD)
      path   = build_path path
      method = build_method method

      @routes.delete [method,path]
    end

    private

    def build_path(path)
      File.join '/', path_prefix, path
    end

    def build_method(method)
      method.to_s.upcase
    end

    def path_prefix
      ENV['GUZZLER_POSTBACK_ENDPOINT_PREFIX'] || '/'
    end
  end
end
