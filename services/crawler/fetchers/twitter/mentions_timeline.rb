require 'twitter'

module Fetchers
  module Twitter

    class MentionsTimeline
      include Protocol

      def initialize(client)
        @client = client
      end

      def fetch
        Celluloid.logger.info "[FETCHER] Fetching Twitter/MentionsTimeline"
        handle_errors do
          @client.mentions_timeline(:count => 200)
        end
      end
    end
  end
end
