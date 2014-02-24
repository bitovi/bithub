module Entities
  module StackExchange

    class Answer < Protocol

      def find
        @payload.origin_id && find_by_origin_id
      end

      def build
        Entity.new({
          title: "answered ##{@payload.question_id}", # @payload.title
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
        build_comments
      end

      def build_comments
        @payload.comments.map do |c|
          Entities::StackExchange::Comment.new(c)
            .procure
            .determine
            .group
            .normalize
            .instance
        end
      end

      def update
        @instance.body = @payload.body_markdown || @payload.body
        @instance.props[:origin_score] = @payload.score
        @instance.props[:is_accepted] = @payload.accepted?
        @instance.props[:upvotes] = @payload.upvote_count
        self
      end

      private

      def find_by_origin_id
        Entity
          .feed('stack_exchange')
          .type('answer')
          .where(origin_id: @payload.origin_id)
          .first
      end

    end

  end
end
