module Identities
  class Builder

    def initialize(strategy, source_data)
      @provider_builder = strategy.new(source_data)
    end

    def extracted_data
      @provider_builder.run.storage
    end

    class Protocol
      def initialize(source_data)
        @source_data = HashWithIndifferentAccess.new(source_data)
        @storage = {}
      end
      attr_reader :storage

      def token
        credentials.fetch :token
      end

      def credentials
        @source_data.fetch :credentials
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
