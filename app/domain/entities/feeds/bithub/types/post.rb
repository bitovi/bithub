module Entities
  module Bithub
    class Post < Protocol

      def find
        Entity.where(id: @payload.id).first
      end

      def build
        Entity.new({
          title: @payload.title,
          body: @payload.body,
          url: @payload.url,
          origin_ts: @payload.origin_ts,
          props: {
            scheduled_for: @payload.scheduled_for,
            location: @payload.location,
            project: @payload.project,
            tags: @payload.category,
            origin_author_id: @payload.origin_author_id,
            origin_author_feed: @payload.origin_author_feed
            #origin_author_name: @payload.origin_author_name
          }
        })
      end

      def update
        @instance.title = @payload.title
        @instance.body = @payload.body
        @instance.url = @payload.url
        @instance.props[:scheduled_for] = @payload.scheduled_for
        @instance.props[:location] = @payload.location
        # TODO tags?
        super
      end

    end
  end
end
