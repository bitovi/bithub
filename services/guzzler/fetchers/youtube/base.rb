module Guzzler::Fetchers

  module Youtube
    class BadRequestError < StandardError; end
    class ForbiddenError < StandardError; end
    class QuotaExceededError < StandardError; end

    class Base
      include Protocol

      def initialize(service)
        @service = service
      end

      def fetch(&block)
        handle_errors do
          result = yield if block_given?

          if result.error?
            err_code = result.data.error['code']
            err_msg  = result.data.error['message']
            msg      = "#{err_code} #{err_msg}"

            case err_code
            when 400
              raise BadRequestError.new msg
            when 403
              raise (/.*quota.*/i.match(err_msg) ? QuotaExceeded.new(msg) : ForbiddenError.new(msg))
            else
              raise msg
            end
          else
            result.data.items.map {|i| i.to_hash}
          end
        end
      end

      def youtube_api
        @youtube_api ||= @client.discovered_api 'youtube', 'v3'
      end

      def client
        return @client if @client

        @client = Google::APIClient.new\
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
       

      def target_id
        @service.config.fetch :id
      end

      def access_token
        @service.config.fetch :access_token
      end

      def refresh_token
        @service.config.fetch :refresh_token
      end
    end
  end
end
