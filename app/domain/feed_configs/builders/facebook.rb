module FeedConfigs
  module Builders
    class Facebook < Base

      def initialize(args)
        super args do
          @conn = create_facebook_client
        end
      end

      def build
        {
          token: access_token,
          pages: pages
        }
      end

      private

      def pages
        @conn.get_connections('me','accounts').map do |page|
          {
            id: page.fetch('id'),
            token: page.fetch('access_token')
          }
        end
      end

      def create_facebook_client
        Koala::Facebook::API.new access_token
      end

      def access_token
        @oauth_data.fetch(:credentials).fetch(:token)
      end

    end
  end
end
