module Entities
  module Disqus

    class Post < Protocol

      def find
        @event.post.id && find_by_post_id.first
      end

      def build
        Entity.new({
          title: @event.thread.title,
          body: @event.post.message,
          url: @event.post.url,
          origin_id: @event.origin_id,
          origin_ts: @event.origin_timestamp,
          props: {
            origin_author_id: @event.origin_author_id,
            origin_author_name: @event.origin_author_name,
          }
        })
      end

      # Finders
      def find_by_post_id
        Entity
        .feed('disqus')
        .type('post')
        .where(origin_id: @event.post.id)
      end

    end

  end
end
