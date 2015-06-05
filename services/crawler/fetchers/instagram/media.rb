require 'instagram'

module Fetchers
  module Instagram
    class Media

      def initialize(media_id, opts={})
        @client   = create_client
        @media_id = media_id
      end

      def fetch(opts)
        Celluloid.logger.info "[FETCHER] Fetching Instagram/Media"
        @result = @client.media_item @media_id
      end

      def self.fetch(media_id, opts={})
        self.new(media_id, opts).fetch
      end

      private

      def create_client
        ::Instagram.client client_id: ENV['INSTAGRAM_CLIENT_ID'], client_secret: ENV['INSTAGRAM_CLIENT_SECRET']
      end

    end
  end
end
