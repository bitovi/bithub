require 'andand'

module Identities
  module Builders
    class Facebook < Builder::Protocol

      def run
        credentials
        long_lived_access_token
        pages
        self
      end

      # fills @storage[:credentials] with user's long lived token
      def long_lived_access_token
        if llt = long_lived_access_token_over_http
          @storage[:credentials] = {} unless @storage[:credentials]
          @storage[:credentials][:long_lived_access_token] = llt
        end
      end

      # if @storage[:long_lived_access_token] has been
      # successfully set by `fetch_long_lived_access_token`
      # page objects should contain no-expiry tokens
      # if not, pages contain tokens that expire
      def pages
        if (ps = pages_over_http)
          @storage[:pages] = ps
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
        @storage.fetch(:long_lived_access_token) {
          @source_data.fetch(:credentials).fetch(:token)
        }
      end
    end
  end
end
