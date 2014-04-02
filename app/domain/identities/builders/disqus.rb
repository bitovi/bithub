module Identities
  module Builders
    class Disqus < Base

      def initialize(args)
        super
        @conn = create_github_client
        self
      end

      def build
        sync_forums
        @data
      end

      def sync_forums
        @data[:forums] = fetch_forums
      end

      # Accessors

      def access_token
        oauth.fetch(:credentials).fetch(:token)
      end

      private

      def fetch_forums

      end

      def create_disqus_client
      end

    end
  end
end
