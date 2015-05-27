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
        handle_errors do
          @client.user_timeline(@handle, :count => 200)
        end
      end
    end
  end
end
