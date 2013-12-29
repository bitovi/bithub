module Entities
  module Forum
    module Post

      Relationships = {
        upstream: [Entities::Forum::Post],
        downstream: [Entities::Forum::Post]
      }

      class Procurer < Entities::Procurer
        include Entities::Forum::Accessors

        def find(payload)
          if url(payload)
            find_by_url(url(payload))
          end
        end

        def build(payload)
          entity = @p.new
          entity.assign_attributes(extracted(payload))
          entity.props = meta(payload)
          entity
        end

        def update(entity, payload)
          entity.assign_attributes(extracted(payload))
          entity
        end

        # Finders
        def find_by_url(url)
          @p.tagged_with('forum').where(:url => url).first
        end

        def find_by_thread_url(url)
          thread_url, _ = url.split('#')
          @p.tagged_with('forum').where("url LIKE '#{thread_url}%'").first
        end
      end

    end
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

