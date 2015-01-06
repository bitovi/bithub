module Entities
  module Tumblr

    class Photo < Post

      def build
        Entity.new({
          title: @event.source_data[:caption],
          url: @event.link,
          origin_ts: @event.created_at,
          origin_id: @event.id,
          props: {
            tags: @event.tags,
            photos: @event.source_data[:photos].to_json,
            origin_author_name: @event.blog_name
          }
        })
      end

    end

  end
end
