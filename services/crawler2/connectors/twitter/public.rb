require_relative 'client'

module Connectors
  module Twitter

    class Public
      include Client

      def configure
        @topics = @config.fetch(:params).fetch(:track)
        self
      end

      def listen
        @client.filter(:track => @topics.join(',')) do |object|
          yield(object)
        end
      end
    end

  end
end
