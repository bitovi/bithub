require_relative 'client'

module Connectors
  module Meetup

    class Rsvps
     # include Celluloid::IO
      include Client

      def configure
        self
      end

      def listen
        @client.rsvps do |object|
          yield(object)
        end
      end
    end

  end
end
