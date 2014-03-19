require_relative 'client'

module Connectors
  module Meetup

    class OpenEventsConnector
      include Client

      def listen
        @client.open_events do |obj|
          yield obj if block_given?
        end
      end
    end

  end
end
