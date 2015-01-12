module Identities
  module Builders
    class Stackexchange < Base

      def credentials(argument = nil)
        { access_token: access_token }
      end

      def access_token
        @data.fetch('oauth').fetch('token')
      end

    end
  end
end
