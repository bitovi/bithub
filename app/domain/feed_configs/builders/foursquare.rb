module FeedConfigs
  module Builders
    class Foursquare < Base

      def initialize(oauth_data)
        @oauth_data = data
      end

      def build
        {
          token: "",
          token_secret: "",
          vanues: [] # ids, prefetch
        }
      end

    end
  end
end
