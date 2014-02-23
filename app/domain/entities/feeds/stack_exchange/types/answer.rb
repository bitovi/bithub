module Entities
  module StackExchange

    class Answer < Protocol

      def find
        nil
      end

      def build
        Entity.new({
          title: @payload.title,
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
            origin_is_accepted: @payload.accepted?,
            origin_upvotes: @payload.upvote_count,
            origin_question_id: @payload.question_id
          }
        })
      end

      def build_children

      end

      def build_comments

      end

    end

  end
end
