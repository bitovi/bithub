module Entities
  module StackExchange

    class Question < Protocol

      def find
        @payload.origin_id && find_by_origin_id
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
            origin_accepted_answer_id: @payload.accepted_answer_id,
            origin_upvotes: @payload.upvote_count
          }
        })
      end

      def build_children
        # return both arrays
        build_comments + build_answers
      end

      def update
        @instance.title = @payload.title
        @instance.body = @payload.body_markdown || @payload.body
        @instance.props[:origin_score] = @payload.score
        @instance.props[:accepted_answer_id] = @payload.accepted_answer_id
        @instance.props[:upvotes] = @payload.upvote_count

        # ?!?!
        update_children
        self
      end

      def update_children
        update_answers
      end

      private

      def find_by_origin_id
        Entity
          .feed('stack_exchange')
          .type('question')
          .where(origin_id: @payload.origin_id)
          .first
      end

      def build_answers
        @payload.answers.map do |a|
          Entities::StackExchange::Answer.new(a)
            .procure
            .determine
            .group
            .normalize
            .instance
        end
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

      def update_answers
        @payload.answers.map do |a|
          Entities::StackExchange::Answer.new(a)
            .procure
            .update
            .determine
            .group
            .normalize
            .persist
        end
      end


    end
  end
end
