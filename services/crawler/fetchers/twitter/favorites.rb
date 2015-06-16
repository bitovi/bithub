require 'twitter'

module Fetchers
  module Twitter

    class Favorites
      include Protocol

      def initialize(client, opts)
        @client = client
        @handle = opts.fetch(:user_handle)
        @count  = opts.fetch(:count) { 200 }
      end

      def fetch
        Celluloid.logger.info "[FETCHER] Fetching Twitter/Favorites"
        handle_errors do
          @client.favorites(@handle, :count => @count)
        end
      end
    end
  end
end
