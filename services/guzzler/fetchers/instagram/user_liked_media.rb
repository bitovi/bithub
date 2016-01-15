require_relative 'base'

module Guzzler::Fetchers

  module Instagram
    class UserLikedMedia < Base
      def initialize(opts={})
        super(nil, opts)
      end

      def fetch_once(opts={})
        log_fetch
        @client.user_liked_media opts
      end
    end
  end
end
