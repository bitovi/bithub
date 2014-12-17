module Identities
  module Builders
    class Tumblr < Base

      def build
        @data
      end

      def credentials
        { access_token: access_token }
      end

      # Accessors

      def access_token
        oauth.fetch(:credentials).fetch(:token)
      end

    end
  end
end
