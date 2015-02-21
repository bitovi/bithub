class Router

  DEFAULT_METHOD = '*'

  module Errors
    class RouteAlreadyExists < StandardError; end
  end

  attr_reader :routes

  def initialize(opts={})
    @routes = {}
    @prefix = opts[:prefix] || ''
  end

  def register(handler, path, method=DEFAULT_METHOD)
    path   = build_path path
    method = build_method method

    if @routes[[method,path]]
      fail Errors::RouteAlreadyExists, "Route #{method} #{path} already exists."
    else
      @routes[[method,path]] = handler
    end
  end

  def unregister(path, method=DEFAULT_METHOD)
    path   = build_path path
    method = build_method method

    @routes.delete [method,path]
  end

  def route(path, method=DEFAULT_METHOD)
    method = build_method method

    @routes[[method,path]] || @routes[[DEFAULT_METHOD, path]]
  end

  private

  def build_path(path)
    File.join '/', @prefix, path
  end

  def build_method(method)
    method.to_s.upcase
  end

end
