module Entities
  module Stackexchange

    class Comment < Protocol

      def find
        @event.comment_id && find_by_origin_id
      end

      def data
        with_commons({
          title: "commented #{@event.post_type} ##{@event.post_id}",
          origin_id: @event.comment_id.to_s,
          props: {
            score: @event.score,
            post_id: @event.post_id,
            post_type: @event.post_type,
          }
        })
      end

      def update
        nil
      end

      private

      def find_by_origin_id
        Entity
          .feed('stackexchange')
          .type('comment')
          .where(origin_id: @event.comment_id.to_s)
          .first
      end

    end
  end
end
