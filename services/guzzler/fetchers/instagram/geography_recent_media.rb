require_relative 'base'

module Guzzler::Fetchers

  module Instagram
    class GeographyRecentMedia < Base
      def fetch_once(opts={})
        log_fetch
        @client.geography_recent_media @object_id, opts
      end
    end

  end
end
