require 'twitter'

module Guzzler::Fetchers

  module Twitter
    class UserRetweets
      include Protocol
      include Twitter::Common

      def initialize(service)
        @service = service
      end

      def fetch
        log_fetch

        handle_errors do
          result = client.user_timeline(handle, :count => count)
          result.select {|tw| tw.retweet? }
        end
      end
    end
  end
end
