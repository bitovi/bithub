module Identities
  module Builders
    class Facebook < Base

      def initialize(args)
        super
        @conn_rest  = create_facebook_client
        @conn_oauth = create_facebook_oauth_client \
          args[:facebook_key] || ENV['FACEBOOK_KEY'],
          args[:facebook_secret] || ENV['FACEBOOK_SECRET']

        self
      end

      def build
        if long_lived_token = fetch_long_lived_token
          @data[:custom][:long_lived_token] = long_lived_token
          @conn_rest = create_facebook_client
        end

        sync_pages
        @data
      end

      def sync_pages
        @data[:pages] = fetch_pages
      end

      # Accessors

      def access_token
        long_lived_token || oauth.fetch(:credentials).fetch(:token)
      end

      def page_ids
        pages.map {|p| p.fetch('id')}
      end

      def page_ids_and_tokens
        pages.map do |page|
          {
            id: page.fetch('id'),
            token: page.fetch('access_token')
          }
        end
      end

      def pages
        @data.fetch(:pages)
      end

      def long_lived_token
        @data.fetch(:custom)[:long_lived_token]
      end

      private

      def fetch_pages
        @conn_rest.get_connections('me','accounts')
      end

      def create_facebook_client(token = access_token)
        Koala::Facebook::API.new token
      end

      def create_facebook_oauth_client(key, secret)
        Koala::Facebook::OAuth.new key, secret
      end

      def fetch_long_lived_token(token = access_token)
        if result = @conn_oauth.exchange_access_token_info(token)
          result['access_token']
        end
      end

    end
  end
end
