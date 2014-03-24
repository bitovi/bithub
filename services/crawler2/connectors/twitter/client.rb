require 'twitter'

module Connectors
  module Twitter

    module Client
      def initialize(cfg)
        @config = cfg
        @client = ::Twitter::Streaming::Client.new({
          tcp_socket_class: Celluloid::IO::TCPSocket,
          ssl_socket_class: Celluloid::IO::SSLSocket
        }) do |config|
          config.consumer_key        = @config.fetch(:oauth).fetch(:consumer_key)
          config.consumer_secret     = @config.fetch(:oauth).fetch(:consumer_secret)
          config.access_token        = @config.fetch(:oauth).fetch(:token)
          config.access_token_secret = @config.fetch(:oauth).fetch(:token_secret)
        end
      end

    end

  end
end
