require_relative 'base'

module Guzzler::Fetchers

  module Instagram
    class UserRecentMedia < Base
      def fetch_once(opts={})
        log_fetch
        @client.user_recent_media @service.config.fetch(:id), opts
      end
    end
  end
end
