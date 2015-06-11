require 'twitter'

module Fetchers
  module Twitter

    class UserRetweets
      include Protocol

      def initialize(client, opts)
        @client = client
        @handle = opts.fetch(:user_handle)
      end

      def fetch
        Celluloid.logger.info "[FETCHER] Fetching Twitter/UserRetweets"
        handle_errors do
          result = @client.user_timeline(@handle, :count => 200)
          result.select {|tw| tw.retweet? }
        end
      end
    end
  end
end
