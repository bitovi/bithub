module Identities
  module BuilderStrategies
    class Protocol

      def initialize(source_data)
        @source_data = HashWithIndifferentAccess.new source_data
        @result = {}
      end
      attr_reader :result

      # fills @result[:credentials] with user's token
      def extract_credentials
        @result[:credentials] = {
          access_token: @source_data.fetch(:credentials).fetch(:token)
        }
      end

      private
      def https_client(domain)
        if !@https_client 
          client = Net::HTTP.new domain, 443
          client.use_ssl = true
          @https_client = client
        else
          @https_client
        end
      end
    end
  end
end
