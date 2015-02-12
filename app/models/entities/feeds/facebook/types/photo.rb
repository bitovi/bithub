module Entities
  module Facebook

    class Photo < Protocol

      def find
        @event.photo.id && find_by_photo_id.first
      end

      def find_by_photo_id
        Entity
        .feed('facebook')
        .type('photo')
        .where(origin_id: @event.photo.id.to_s)
      end

      def build
        Entity.new({
          title: title,
          body: @event.message,
          url: @event.link,
          origin_id: @event.id,
          origin_ts: @event.created_time,
          is_pending: true,
          props: {
            origin_id: @event.id,
            origin_object_id: @event.photo_id,
            origin_author_id: @event.from.id,
            origin_author_name: @event.from.name,
            image_url: @event.source
          }
        })
      end

      private

      def title
        "#{@event.from.name} posted: #{@event.type}"
      end

    end

  end
end
