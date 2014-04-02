module Identities
  module Builders
    class Meetup < Base

      def initialize(args)
        super
        @conn = create_meetup_client
        self
      end

      def build
        sync_groups
        @data
      end

      def sync_groups
        @data[:groups] = fetch_groups
      end

      # Accessors

      def groups
        @data[:groups]
      end

      def access_token
        oauth.fetch(:credentials).fetch(:token)
      end

      private

      def fetch_groups

      end

      def create_meetup_client

      end

    end
  end
end
