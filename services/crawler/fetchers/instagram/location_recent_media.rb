require_relative 'base'

module Fetchers
  module Instagram

    class LocationRecentMedia < Base
      def fetch_once(opts={})
        Celluloid.logger.info "[FETCHER] Fetching Instagram/LocationRecentMedia"
        @client.location_recent_media @object_id, opts
      end
    end

  end
end
