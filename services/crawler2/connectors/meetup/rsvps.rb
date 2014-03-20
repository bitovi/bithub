require_relative 'client'

module Connectors
  module Meetup

    class Rsvps
      include Client

      def configure
        self
      end

      def listen
        @client.rsvps do |obj|
          yield obj if block_given?
        end
      end
    end

  end
end
