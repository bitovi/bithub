module Identities
  module BuilderStrategies
    class Twitter < Protocol

      def run
        extract_credentials
      end

      def extract_credentials
        @result[:credentials] = super.merge({
          access_secret: @source_data.fetch(:credentials).fetch(:secret)
        })
      end
    end
  end
end
