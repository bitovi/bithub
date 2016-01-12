require 'guzzler/error'

module Guzzler::Listener
  class Router

    DEFAULT_METHOD = '*'

    def initialize(opts={})
      @routes = {}
      @prefix = opts[:prefix] || ''
    end
    attr_reader :routes
    
    def route(path, method=DEFAULT_METHOD)
      method = build_method method
      @routes[[method,path]] || @routes[[DEFAULT_METHOD, path]]
    end

    def register_handler(path, handler, method=DEFAULT_METHOD)
      path   = build_path path
      method = build_method method

      if @routes[[method,path]]
        fail Guzzler::HandlerAlreadyRegisteredError, "Handler #{handler} already registered for #{method} #{path}."
      else
        @routes[[method,path]] = handler
      end
    end

    def unregister_handler(path, method=DEFAULT_METHOD)
      path   = build_path path
      method = build_method method

      @routes.delete [method,path]
    end

    private

    def build_path(path)
      File.join '/', @prefix, path
    end

    def build_method(method)
      method.to_s.upcase
    end

  end
end
