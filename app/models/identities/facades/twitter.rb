module Identities
  module Facades
    class Twitter < Facade::Protocol

      def access_secret
        @source_data.fetch(:credentials).fetch(:secret)
      end
    end
  end
end
