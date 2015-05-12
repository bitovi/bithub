module Fetchers
  module Youtube

    class Base
      include Protocol

      def initialize(client, opts)
        @client = client
        @opts   = opts
      end

      def fetch(&block)
        result = yield if block_given?

        # TODO: handle errors

        result.data.items.map {|i| i.to_hash}
      end

      def youtube_api
        @youtube_api ||= @client.discovered_api 'youtube', 'v3'
      end

    end
  end
end
