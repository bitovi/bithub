module Identities
  module Facades
    class Twitter < Facade::Protocol

      def credentials(property_id = nil)
        { access_token: access_token, access_secret: access_secret }
      end

      private

      def access_token
        @source_data.fetch(:credentials).fetch(:token)
      end

      def access_secret
        @source_data.fetch(:credentials).fetch(:secret)
      end

    end
  end
end
