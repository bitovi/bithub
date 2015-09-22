require 'twitter'

module Guzzler::Fetchers

  module Twitter
    module Common

      def client
        @client ||= ::Twitter::REST::Client.new do |config|
          config.consumer_key        = Guzzler.static_config.fetch(:twitter).fetch(:api_key)
          config.consumer_secret     = Guzzler.static_config.fetch(:twitter).fetch(:api_secret)
          config.access_token        = @job.token
          config.access_token_secret = @job.config.fetch('access_secret')
        end
      end
       
      def count
        @job.config.fetch('count') { 200 }
      end

      def handle
        @job.config.fetch('handle')
      end
    end
  end
end
