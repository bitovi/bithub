module Identities
  module BuilderStrategies
    class Instagram < Protocol

      def run
        extract_credentials
      end

    end
  end
end
