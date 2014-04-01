module FeedConfigs
  module Builders
    class Meetup < Base

      def initialize(oauth_data)
        @oauth_data = data
      end

      def build
        {
          token: "",
          token_secret: "",
          terms: [],
          groups: [] #ids, prefetch
        }
      end

    end
  end
end
