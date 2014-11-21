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
      rescue ::Twitter::Error::Unauthorized => e
        Celluloid.logger.error "#{e.class.name} -> #{e.to_s}"
        nil
      end

    end
  end
end
