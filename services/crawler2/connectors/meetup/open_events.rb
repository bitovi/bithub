require_relative 'client'

module Connectors
  module Meetup

    class OpenEvents
      include Client

      def configure
        self
      end

      def listen
        @client.open_events do |object|
          yield(object)
        end
      end
    end

  end
end
