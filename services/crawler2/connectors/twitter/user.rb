require_relative 'client'

module Connectors
  module Twitter

    class User
      include Client

      def configure
        self
      end

      def listen
        @client.user do |object|
          yield(object)
        end
      end
    end

  end
end
