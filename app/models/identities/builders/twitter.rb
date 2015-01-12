module Identities
  module Builders
    class Twitter < Base

      def credentials(argument = nil)
        {
          access_token: access_token,
          access_secret: access_secret
        }
      end

      def access_token
        oauth.fetch(:credentials).fetch(:token)
      end

      def access_secret
        oauth.fetch(:credentials).fetch(:secret)
      end

    end
  end
end
