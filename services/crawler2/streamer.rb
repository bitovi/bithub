class Streamer
  include Celluloid::IO

  def initialize(name, cfg, connector_class)
    @feed_name, @endpoint_name = name; @config = cfg
    @connector = connector_class.new(@config)

    async.stream
  end

  def stream
    Celluloid.logger.info "Streaming #{@feed_name}:#{@endpoint_name}"
    connect
  end

  def connect
    @connector.configure.listen do |resp|
      Celluloid.logger.info "STREAMED #{@feed_name}:#{@endpoint_name} ---> new stuff"
      resp
    end
  end
end
