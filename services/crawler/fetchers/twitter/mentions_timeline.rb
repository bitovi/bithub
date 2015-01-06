require 'twitter'

module Fetchers
  module Twitter

    class MentionsTimeline
      include Protocol

      def initialize(client)
        @client = client
      end

      def fetch
        @client.mentions_timeline
      end
    end
  end
end
