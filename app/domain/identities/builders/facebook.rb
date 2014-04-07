module Identities
  module Builders
    class Facebook < Base

      def initialize(args)
        super
        @conn = create_facebook_client
        self
      end

      def build
        sync_pages
        @data
      end

      def sync_pages
        @data[:pages] = fetch_pages
      end

      # Accessors

      def access_token
        oauth.fetch(:credentials).fetch(:token)
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

      private

      def fetch_pages
        @conn.get_connections('me','accounts')
      end

      def create_facebook_client
        Koala::Facebook::API.new access_token
      end

    end
  end
end
