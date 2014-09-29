module Identities
  module Builders
    class Twitter < Base

      def access_token
        oauth.fetch(:credentials).fetch(:token)
      end

      def access_secret
        oauth.fetch(:credentials).fetch(:secret)
      end

    end
  end
end
