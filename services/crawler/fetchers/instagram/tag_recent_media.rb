require_relative 'base'

module Fetchers
  module Instagram

    class TagRecentMedia < Base
      def fetch_once(opts={})
        @client.tag_recent_media @object_id, opts
      end
    end

  end
end
