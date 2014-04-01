module FeedConfigs
  module Builders
    class Twitter < Base

      def build(args={})
        {
          token: access_token,
          token_secret: access_secret,
          terms: args.fetch(:terms) {[]}
        }
      end

      private

      def access_token
        @oauth_data.fetch(:credentials).fetch(:token)
      end

      def access_secret
        @oauth_data.fetch(:credentials).fetch(:secret)
      end

    end
  end
end
