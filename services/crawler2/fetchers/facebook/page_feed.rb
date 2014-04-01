require 'koala'

module Fetchers
  module Facebook

    class PageFeed
      include Protocol

      def initialize(client, opts = {})
        @client = client
      end

      def fetch
        @client.get_connections('me', 'feed', {:limit => 50})
      end
    end
  end
end
