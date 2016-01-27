require_relative 'common'

module Guzzler::Fetchers

  module Tumblr
    class Posts
      include Protocol
      include Tumblr::Common

      # http://www.tumblr.com/docs/en/api/v2#posts
      LIMIT = 20

      def initialize(service)
        @service = service
        @offset = 0
      end

      def fetch
        log_fetch

        handle_errors do
          @result = client.posts hostname, limit: @limit, offset: @offset
          @result.fetch('posts')
        end
      end

      def hostname
        @service.config.fetch(:hostname)
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
