require 'twitter'

module Fetchers
  module Twitter

    class UserTimeline
      include Protocol

      def initialize(client, opts)
        @client = client
        @handle = opts.fetch(:user_handle)
      end

      def fetch
        @client.user_timeline(@handle)
      end
    end
  end
end
