require_relative 'base'
require_relative '../protocol'

module Fetchers
  module Tumblr

    class Posts < Base
      include Protocol
      # http://www.tumblr.com/docs/en/api/v2#posts

      def initialize(hostname, opts={})
        super opts
        @hostname = hostname
        @offset = 0
      end

      def fetch
        Celluloid.logger.info "[FETCHER] Fetching Tumblr/Posts"
        handle_errors do
          @result = @client.posts @hostname, limit: @limit, offset: @offset
          @result.fetch('posts')
        end
      end

      def next
        if has_next?
          @offset += LIMIT
          fetch
        end
      end

      def reset
        @offset = 0
      end

      private

      def has_next?
        @offset <= @result['total_posts']
      end

      def self.fetch(hostname, opts={})
        self.new(hostname, opts).fetch
      end

    end

  end
end
