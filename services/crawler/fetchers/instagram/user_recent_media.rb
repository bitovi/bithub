module Fetchers
  module Instagram

    class UserRecentMedia < Base

      COUNT = 100

      def initialize(user_id)
        super()
        @user_id = user_id
      end

      def fetch(opts={})
        # user_id or access_token

        count      = opts[:count] || COUNT
        max_id     = opts[:max_id]

        if max_id
          @result = @client.user_recent_media @user_id, count: count, max_id: max_id
        else
          @result = @client.user_recent_media @user_id, count: count
        end

        @result
      end

      def has_next?
        @result && @result.pagination.andand("next_max_id")
      end

      def next
        if next_max_id = has_next?
          @result = fetch max_id: next_max_id
        end
      end

      def reset
        @result = nil
      end

      def self.fetch(user_id, opts={})
        self.new(user_id, opts).fetch opts
      end

    end

  end
end
