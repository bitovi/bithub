require_relative 'base'

module Fetchers
  module Instagram

    class UserRecentMedia < Base
      def fetch_once(opts={})
        @client.user_recent_media @object_id, opts
      end
    end

  end
end
