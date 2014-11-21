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
      rescue ::Twitter::Error::Unauthorized => e
        Celluloid.logger.error "#{e.class.name} -> #{e.to_s}"
        nil
      end

    end
  end
end
