require_relative 'common'

module Guzzler::Fetchers

  module Twitter
    class MentionsTimeline
      include Protocol
      include Twitter::Common

      def initialize(service)
        @service = service
      end

      def fetch
        log_fetch
        handle_errors do
          client.mentions_timeline(:count => count)
        end
      end
    end
  end
end
