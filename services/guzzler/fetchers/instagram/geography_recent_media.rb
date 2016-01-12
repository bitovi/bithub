require_relative 'base'

module Guzzler
  module Fetchers

    module Instagram
      class GeographyRecentMedia < Base
        def fetch_once(opts={})
          Celluloid.logger.info "[FETCHER] Fetching Instagram/GeographyRecentMedia"
          @client.geography_recent_media @object_id, opts
        end
      end

    end
  end
end
