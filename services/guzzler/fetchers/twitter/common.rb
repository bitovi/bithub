require 'twitter'

module Guzzler::Fetchers

  module Twitter
    module Common

      def client
        @client ||= ::Twitter::REST::Client.new do |config|
          config.consumer_key        = Guzzler.static_config.fetch(:twitter).fetch(:api_key)
          config.consumer_secret     = Guzzler.static_config.fetch(:twitter).fetch(:api_secret)
          config.access_token        = @service.token
          config.access_token_secret = @service.config.fetch(:access_secret)
        end
      end

      def count
        @service.config.fetch(:count) { 200 }
      end

      def handle
        @service.config.fetch(:handle)
      end
    end
  end
end
