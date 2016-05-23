require 'bits/protocol'

module Bits
  module Disqus

    class Post < Protocol

      def find
        @event.post.id && find_by_post_id.first
      end

      def data
        {
          title: @event.thread.title,
          body: @event.post.message,
          url: @event.post.url,
          origin_id: @event.post.id,
          origin_ts: @event.post.created_at,
          searchable_author: @event.author.name,
          props: {
            origin_author_id: @event.author.id,
            origin_author_name: @event.author.name,
          }
        }
      end

      # Finders
      def find_by_post_id
        Bit
        .feed('disqus')
        .type('post')
        .where(origin_id: @event.post.id)
      end

    end

  end
end
