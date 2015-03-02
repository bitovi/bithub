require 'tumblr_client'
require_relative 'base'

module Fetchers
  module Tumblr

    class Base
      LIMIT = 20 # API limit

      attr_reader :client, :result

      def initialize(opts={})
        @client = create_client opts
        @limit  = opts[:limit] || LIMIT
      end

      private

      def create_client(opts={})
        key    = opts[:consumer_key] || ENV['TUMBLR_CLIENT_ID']
        secret = opts[:consumer_secret] || ENV['TUMBLR_CLIENT_SECRET']

        ::Tumblr::Client.new consumer_key: key, consumer_secret: secret
      end

      def log_error(meta)
        Celluloid.logger.info " #{meta.code}: #{meta.error_type} #{meta.error_message}"
      end

      def publisher
        Celluloid::Actor[:event_publisher]
      end

    end

  end
end
