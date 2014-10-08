module Entities
  module Tumblr

    class Text < Post

      def build
        Entity.new({
          title: @event.source_data[:title] || "undefined",
          url: @event.link,
          body: @event.source_data[:body],
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
