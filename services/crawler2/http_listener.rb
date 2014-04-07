require 'reel'

class HttpListener < Reel::Server::HTTP
  include Streamers::Registrable

  def initialize(host = "127.0.0.1", port = 3000)
    super(host, port, &method(:on_connection))

    Celluloid.logger.info "Started HTTP server on http://#{host}:#{port}"
  end

  def on_connection(connection)
    connection.each_request do |request|
      response = route_request request

      Celluloid.logger.info "HTTP Listener: #{request.method} #{request.path} --> #{response.status} #{response.body}"

      request.respond response
    end
  end

  private

  def route_request(request)
    feed, type = parse_req_path request.path

    if handler = fetch_handler(feed, type)
      handler.new(request).handle
    else
      Reel::Response.new :not_found, "Handler not found"
    end
  end

  def fetch_handler(feed, type)
    HttpHandlers.const_get(feed).const_get(type)
  rescue
    nil
  end

  def parse_req_path(path)
    path.split("/")[1..-1].map {|x| x.camel_case.to_sym}
  end

end
