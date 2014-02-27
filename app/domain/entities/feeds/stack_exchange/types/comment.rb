module Entities
  module StackExchange

    class Comment < Protocol

      def find
        @event.comment_id && find_by_origin_id
      end

      def build
        Entity.new({
          title: "commented #{@event.post_type} ##{@event.post_id}",
          body: @event.body_markdown || @event.body,
          url: @event.link,
          origin_ts: @event.creation_date,
          origin_id: @event.comment_id.to_s,
          props: {
            origin_author_id: @event.owner.id,
            origin_author_name: @event.owner.name,
            origin_author_avatar_url: @event.owner.profile_image,
            score: @event.score,
            post_id: @event.post_id,
            post_type: @event.post_type,
          }
        })
      end

      def update
        @instance
      end

      private

      def find_by_origin_id
        Entity
          .feed('stack_exchange')
          .type('comment')
          .where(origin_id: @event.comment_id.to_s)
          .first
      end


    end

  end
end
