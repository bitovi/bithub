require_relative 'base'

module Guzzler
  module Fetchers

    module Instagram

      class TagRecentMedia < Base
        def fetch_once(opts={})
          Celluloid.logger.info "[FETCHER] Fetching Instagram/TagRecentMedia"
          @client.tag_recent_media @object_id, opts
        end
      end

    end
  end

end
