module Identities
  module Builders
    class Instagram < Builder::Protocol

      def run
        credentials
        self
      end

    end
  end
end
