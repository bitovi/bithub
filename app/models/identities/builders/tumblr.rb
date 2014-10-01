module Identities
  module Builders
    class Tumblr < Base

      def build
        @data
      end

      # Accessors

      def access_token
        oauth.fetch(:credentials).fetch(:token)
      end

    end
  end
end
