module Supervisors::Services::Youtube
  module Common

    def client
      @client ||= Google::APIClient.new\
        application_name: 'Bithub',
        application_version: '0.0.1'

      if access_token && refresh_token
        @client.authorization.access_token  = access_token
        @client.authorization.refresh_token = refresh_token
        @client.authorization.client_id     = ENV['GOOGLE_CLIENT_ID']
        @client.authorization.client_secret = ENV['GOOGLE_CLIENT_SECRET']
      else
        @client.key                         = ENV['GOOGLE_API_KEY']
        @client.authorization               = nil
      end

      @client
    end

    def access_token
      service_config[:access_token]
    end

    def refresh_token
      service_config[:refresh_token]
    end

    def target_id
      service_config.fetch :id
    end

  end
end
