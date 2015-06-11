require_relative 'base'

module Fetchers
  module Instagram

    class UserLikedMedia < Base

      def initialize(opts={})
        super(nil, opts)
      end

      def fetch_once(opts={})
        Celluloid.logger.info "[FETCHER] Fetching Instagram/UserLikedMedia"
        @client.user_liked_media opts
      end
    end

  end
end
