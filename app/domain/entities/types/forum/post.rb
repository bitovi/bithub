module Entities
  module Forum
    class Post

      def initialize
        @ar = Entity
      end

      def forum_posts_by_thread_url(thread_url)
        query = {
          tags: %w(forums),
          url: "LIKE '#{thread_url}%'"
        }
      end


      # PROTO

      def group_forum_post
        thread_url, _ = url.split('#')
        other_replies = @ar.build_query(forum_posts_by_thread_url(thread_url)).execute #.order('origin_ts ASC')

        if other_replies.length > 0
          if origin_ts > other_replies.first.origin_ts
            self.parent = other_replies.first
          else
            self.children += other_replies.all
          end
        end
        self
      end

    end
  end
end
