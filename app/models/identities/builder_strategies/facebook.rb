require 'andand'

module Identities
  module BuilderStrategies
    class Facebook < Protocol

      def run
        extract_credentials
        fetch_long_lived_access_token
        fetch_pages
      end

      # fills @result[:credentials] with user's long lived token
      def fetch_long_lived_access_token
        if (llt = long_lived_access_token_over_http)
          @result[:credentials] = {} if @result[:credentials].nil?
          @result[:credentials][:long_lived_access_token] = llt
        end
      end

      # if @result[:long_lived_access_token] has been
      # successfully set by `fetch_long_lived_access_token`
      # page objects should contain no-expiry tokens
      # if not, pages contain tokens that expire
      def fetch_pages
        if (pages = pages_over_http)
          @result[:pages] = pages
        end
      end

      private
      def pages_over_http
        facebook_api_client.get_connections('me','accounts')
      end

      def long_lived_access_token_over_http
        if (response = facebook_oauth_client.exchange_access_token_info(
            @source_data.fetch(:credentials).fetch(:token)))
          response['access_token']
        end
      end

      def facebook_api_client
        Koala::Facebook::API.new long_lived_or_regular_token
      end

      def facebook_oauth_client
        Koala::Facebook::OAuth.new ENV['FACEBOOK_CLIENT_ID'], ENV['FACEBOOK_CLIENT_SECRET']
      end

      def long_lived_or_regular_token
        @result.fetch(:long_lived_access_token) {
          @source_data.fetch(:credentials).fetch(:token)
        }
      end
    end
  end
end
