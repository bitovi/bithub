require 'andand'

module Identities
  module Builders
    class Facebook < Base

      def initialize(args)
        super
        @conn_rest  = create_facebook_client
        @conn_oauth = create_facebook_oauth_client \
          args[:facebook_key] || ENV['FACEBOOK_CLIENT_ID'],
          args[:facebook_secret] || ENV['FACEBOOK_CLIENT_SECRET']

        self
      end

      def build
        if long_lived_token = fetch_long_lived_access_token
          @data[:long_lived_access_token] = long_lived_token

          # create new connector with long lived token
          @conn_rest = create_facebook_client long_lived_token
        end

        # page objects should now contain no-expiry tokens
        sync_pages
        @data
      end

      def sync_pages
        @data[:pages] = fetch_pages
      end

      def suggestions(type=nil)
        page_ids_and_names
      end

      def credentials(page_id = nil)
        if page_id
          page_credentials(page_id)
        else
          { access_token: access_token } # user_credentials
        end
      end

      def page_credentials(page_id)
        if (page = pages.select{|p| p.fetch('id') == page_id}.first)
          { access_token: page.fetch('access_token') }
        else
          {}
        end
      end

      # Accessors

      def access_token
        long_lived_access_token || oauth.fetch(:credentials).fetch(:token)
      end

      def page_ids_and_names
        pages.map do |p|
          {
            id: p['id'],
            name: p['name']
          }
        end
      end

      def pages
        @data[:pages] || []
      end

      def long_lived_access_token
        @data[:long_lived_access_token]
      end

      private

      def fetch_pages
        @conn_rest.get_connections('me','accounts')
      end

      def fetch_long_lived_access_token(token = access_token)
        if response = @conn_oauth.exchange_access_token_info(token)
          response['access_token']
        end
      end

      def create_facebook_client(token = access_token)
        Koala::Facebook::API.new token
      end

      def create_facebook_oauth_client(key, secret)
        Koala::Facebook::OAuth.new key, secret
      end

    end
  end
end
