module Grouping
  class Forums

    def initialize
    end

    def group_forums
      group_forum_post if tag_list.include?('forums')
      self
    end

    def group_forum_post
      thread_url, _ = url.split('#')
      other_replies = Event.forum_posts_by_thread_url(thread_url).order('origin_ts ASC')

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
