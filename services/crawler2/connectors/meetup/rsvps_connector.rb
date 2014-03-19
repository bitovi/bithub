require_relative 'client'

module Connectors
  module Meetup

    class RsvpsConnector
      include Client

      def listen
        @client.rsvps do |obj|
          yield obj if block_given?
        end
      end
    end

  end
end
