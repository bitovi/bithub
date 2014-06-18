module Entities
  module Stackexchange

    class Comment < Protocol

      def find
        @payload.comment_id && find_by_origin_id
      end

      def build
        Entity.new({
          title: "commented #{@payload.post_type} ##{@payload.post_id}",
          body: @payload.body_markdown || @payload.body,
          url: @payload.link,
          origin_ts: @payload.creation_date,
          origin_id: @payload.comment_id.to_s,
          props: {
            origin_author_id: @payload.origin_author_id,
            origin_author_name: @payload.origin_author_name,
            origin_author_avatar_url: @payload.origin_author_avatar_url,
            score: @payload.score,
            post_id: @payload.post_id,
            post_type: @payload.post_type,
          }
        })
      end

      def update
        @instance
      end

      private

      def find_by_origin_id
        Entity
          .feed('stackexchange')
          .type('comment')
          .where(origin_id: @payload.comment_id.to_s)
          .first
      end


    end

  end
end
