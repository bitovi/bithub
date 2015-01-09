require 'twitter'

module Fetchers
  module Twitter

    class MentionsTimeline
      include Protocol

      def initialize(client)
        @client = client
      end

      def fetch
        handle_errors do
          @client.mentions_timeline
        end
      end
    end
  end
end
