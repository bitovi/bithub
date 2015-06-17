module Entities
  module Youtube

    class Video < Protocol

      def find
        @event.id && find_by_video_id.first
      end

      def find_by_video_id
        Entity
        .feed('youtube')
        .type('video')
        .where(origin_id: @event.id)
      end

      def build
        Entity.new({
          title: @event.title,
          body: @event.description,
          url: url,
          origin_id: @event.id,
          origin_ts: @event.created_time,
          image: @event.thumbnail,
          searchable_author: @event.channel_title,
          props: {
            origin_author_id: @event.channel_id,
            origin_author_name: @event.channel_title,
          }
        })
      end

      private

      def url
        "https://www.youtube.com/watch?v=#{@event.id}"
      end

    end
  end
end
