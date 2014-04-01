module FeedConfigs
  module Builders
    class Disqus < Base

      def initialize(oauth_data)
        @oauth_data = data
      end

      def build
        {
          token: "",
          token_secret: "",
          forums: [] # names, prefetch
        }
      end

    end
  end
end
