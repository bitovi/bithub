require 'meetup/streaming/client'

module Streamers
  module Meetup

    class Rsvps
      include Celluloid::IO

      def initialize
        @client = ::Meetup::Streaming::Client.new(tcp_socket_class: Celluloid::IO::TCPSocket)
        async.connect
      end

      def connect
        @client.rsvps do |object|
          puts "RSVP" # p object
        end

        Celluloid.logger.info "Streaming meetup:rsvps"
        link(@client)
      end

      def reconnect
        Celluloid.logger.info "Reconnecting meetup:rsvps"
        @client.terminate
        connect
      end
    end
  end
end
