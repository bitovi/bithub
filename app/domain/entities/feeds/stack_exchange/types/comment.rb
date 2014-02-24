module Entities
  module StackExchange

    class Comment < Protocol

      def find
        @payload.origin_id && find_by_origin_id
      end

      def build
        Entity.new({
          title: "commented #{@payload.post_type} ##{@payload.post_id}",
          body: @payload.body_markdown || @payload.body,
          url: @payload.link,
          origin_ts: @payload.origin_ts,
          origin_id: @payload.origin_id,
          props: {
            origin_author_id: @payload.origin_author_id,
            origin_author_name: @payload.origin_author_name,
            origin_author_avatar_url: @payload.origin_author_avatar_url,
            origin_author_url: @payload.origin_author_url,
            origin_score: @payload.score,
            origin_post_id: @payload.post_id,
            origin_post_type: @payload.post_type,
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
          .where(origin_id: @payload.origin_id)
          .first
      end


    end

  end
end
