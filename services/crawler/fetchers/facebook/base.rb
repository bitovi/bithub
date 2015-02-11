require 'koala'

module Fetchers
  module Facebook
    class Base
      include Protocol

      COUNT = 250

      def initialize(client)
        @client = client
      end

      def refresh_token
        # do nothing for now
      rescue Koala::Facebook::AuthenticationError => e
        e
      end

      def handle_errors
        yield
      rescue Koala::Facebook::AuthenticationError => e
        refresh_token
      rescue Koala::Facebook::OAuthSignatureError => e
        refresh_token
      rescue Koala::KoalaError => e
        e
      end

      def self.fetch(client, *args)
        self.new(client).fetch(args)
      end

    end
  end
end
