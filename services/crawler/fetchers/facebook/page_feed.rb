require 'koala'

module Fetchers
  module Facebook

    class PageFeed
      include Protocol

      def initialize(client, opts = {})
        @client = client
      end

      def fetch
        handle_errors do
          @client.get_connections('me', 'feed', {:limit => 100})
        end
      end
    end
  end
end
