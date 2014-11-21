module Supervisors::Services::Twitter
  module Common

    def user_handle
      service_config.fetch(:handle)
    end

    def client
      ::Twitter::REST::Client.new do |config|
        config.consumer_key        = api_key
        config.consumer_secret     = api_secret
        config.access_token        = token
        config.access_token_secret = token_secret
      end
    end

    def token_secret
      service_config.fetch(:access_secret)
    end

    def api_key
      static_config.fetch(:twitter).fetch(:api_key)
    end

    def api_secret
      static_config.fetch(:twitter).fetch(:api_secret)
    end
  end
end
