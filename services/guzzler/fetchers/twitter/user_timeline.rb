require 'twitter'

module Guzzler::Fetchers

  module Twitter
    class UserTimeline
      include Protocol
      include Twitter::Common

      def initialize(service)
        @service = service
      end

      def fetch
        log_fetch

        handle_errors do
          client.user_timeline(handle, :count => count)
        end
      end
    end
  end
end
