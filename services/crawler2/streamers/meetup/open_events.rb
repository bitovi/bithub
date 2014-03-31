require 'meetup/streaming/client'

module Streamers
  module Meetup

    class OpenEvents
      include Celluloid

      def initialize
        @client = ::Meetup::Streaming::Client.new
        async.connect
      end

      def connect
        @client.open_events do |object|
          puts "OPEN_EVENT" # p object
        end

        Celluloid.logger.info "Streaming meetup:open_events"
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
