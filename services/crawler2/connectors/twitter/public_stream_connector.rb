require_relative 'client'

module Connectors
  module Twitter

    class TwitterPublicStreamConnector
      include Client

      def configure
        @topics = @config.fetch(:params).fetch(:track)
      end

      def listen
        @client.filter(:track => @topics.join(",")) do |obj|
          yield obj if block_given?
        end
      end
    end

  end
end
