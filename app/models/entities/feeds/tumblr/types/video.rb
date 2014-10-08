module Entities
  module Tumblr

    class Video < Post

      def build
        Entity.new({
          title: @event.source_data[:caption],
          body: @event.source_data[:player].last[:embed_code],
          url: @event.link,
          origin_ts: @event.created_at,
          origin_id: @event.id,
          props: {
            tags: @event.tags,
            origin_author_name: @event.blog_name
          }
        })
      end

    end

  end
end
