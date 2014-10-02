require_relative 'base'

module Fetchers
  module Tumblr

    class Posts < Base
      # http://www.tumblr.com/docs/en/api/v2#posts

      def initialize(hostname, opts={})
        super opts
        @hostname = hostname
        @offset = 0
      end

      def fetch
        @result = @client.posts @hostname, offset: @offset
        @result.fetch('posts')
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

    end

  end
end
