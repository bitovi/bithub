require_relative 'base'

module Guzzler::Fetchers

  module Instagram
    class LocationRecentMedia < Base
      def fetch_once(opts={})
        log_fetch
        @client.location_recent_media @object_id, opts
      end
    end
  end
end
