module FeedConfigs
  module Builders
    class Irc

      def initialize(oauth_data)
        @oauth_data = data
      end

      def build
        {
          server: '',
          channels: []
        }
      end

    end
  end
end
