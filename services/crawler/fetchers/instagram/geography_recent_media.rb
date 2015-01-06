require_relative 'base'

module Fetchers
  module Instagram

    class GeographyRecentMedia < Base
      def fetch_once(opts={})
        @client.geography_recent_media @object_id, opts
      end
    end

  end
end
