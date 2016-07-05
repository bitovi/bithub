require_relative 'base'

module Guzzler::Fetchers

  module Instagram
    class TagRecentMedia < Base
      def fetch_once(opts={})
        log_fetch

        @client.tag_recent_media @service.config.fetch(:tag), opts
      end
    end
  end
end
