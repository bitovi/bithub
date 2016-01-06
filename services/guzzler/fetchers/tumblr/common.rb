require 'tumblr_client'

module Guzzler::Fetchers

  module Tumblr
    module Common
      def client
        @client ||= ::Tumblr::Client.new consumer_key: key, consumer_secret: secret
      end

      private

      def key
        @job.config['consumer_key'] || Guzzler.static_config.fetch(:tumblr).fetch(:api_key)
      end

      def secret
        @job.config['consumer_secret'] || Guzzler.static_config.fetch(:tumblr).fetch(:api_secret)
      end
    end
  end
end
