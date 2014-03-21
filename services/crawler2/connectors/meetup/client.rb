require 'meetup/streaming/client'

module Connectors
  module Meetup

    module Client
      def initialize(cfg)
        @client = ::Meetup::Streaming::Client.new(tcp_socket_klass: Celluloid::IO::TCPSocket)
      end
    end

  end
end
