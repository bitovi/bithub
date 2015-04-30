module Entities
  module Facebook

    class Photo < Protocol
      include Facebook::SharedBuilders

      def find
        @event.photo.id && find_by_photo_id.first
      end

      def find_by_photo_id
        Entity
        .feed('facebook')
        .type('photo')
        .where(origin_id: @event.photo.id.to_s)
      end

      def data
        with_commons({
          props: {
            origin_object_id: @event.photo_id,
            photos: JSON.generate(@event.images)
          }
        })
      end

      def update
        @instance.props[:origin_author_name] = @event.from.name
      end

    end
  end
end
