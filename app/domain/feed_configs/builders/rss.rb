module FeedConfigs
  module Builders
    class Rss

      def initialize(oauth_data)
        @oauth_data = data
      end

      def build
        {
          urls: []
        }
      end

    end
  end
end
