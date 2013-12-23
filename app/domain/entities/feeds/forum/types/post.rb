module Entities
  module Forum
    module Post

      Relationships = {
        upstream: [Entities::Forum::Post],
        downstream: [Entities::Forum::Post]
      }

      class Procurer < Entities::Procurer
      end

      module Finders
        def find_forum_posts_by_thread_url(thread_url)
          tagged_with('forums').where("url LIKE '#{thread_url}%'")
        end
      end


      # grouping
      # --------
      # def group_forum_post
      #   thread_url, _ = url.split('#')
      #   other_replies = @ar.build_query(forum_posts_by_thread_url(thread_url)).execute #.order('origin_ts ASC')

      #   if other_replies.length > 0
      #     if origin_ts > other_replies.first.origin_ts
      #       self.parent = other_replies.first
      #     else
      #       self.children += other_replies.all
      #     end
      #   end
      #   self
      # end

    end
  end
end
