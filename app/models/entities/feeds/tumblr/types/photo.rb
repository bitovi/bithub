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
            photos: JSON.generate(@event.source_data[:photos]),
            origin_author_name: @event.blog_name
          }
        })
      end

    end

  end
end
