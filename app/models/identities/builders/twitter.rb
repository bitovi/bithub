module Identities
  module Builders
    class Twitter < Builder::Protocol

      def run
        credentials
        self
      end

      def credentials
        @storage[:credentials] = super.merge({
          access_secret: @source_data.fetch(:credentials).fetch(:secret)
        })
      end
    end
  end
end
