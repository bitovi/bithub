module Entities
  module Stackexchange

    class Answer < Protocol

      def find
        @payload.answer_id && find_by_origin_id
      end

      def build
        Entity.new({
          title: "answered ##{@payload.question_id}", # @payload.title
          body: @payload.body_markdown,
          url: @payload.link,
          origin_ts: @payload.creation_date,
          origin_id: @payload.answer_id.to_s,
          props: {
            origin_author_id: @payload.origin_author_id,
            origin_author_name: @payload.origin_author_name,
            origin_author_avatar_url: @payload.origin_author_avatar_url,
            score: @payload.score,
            is_accepted: @payload.accepted?,
            upvote_count: @payload.upvote_count,
            question_id: @payload.question_id
          }
        })
      end

      def update
        @instance.body = @payload.body_markdown || @payload.body
        @instance.props[:origin_score] = @payload.score
        @instance.props[:is_accepted] = @payload.accepted?
        @instance.props[:upvote_count] = @payload.upvote_count
        self
      end


      def build_children
        build_comments.to_a
      end

      def build_comments
        @payload.comments.map do |c| # Wrappers
          Events::Stackexchange::Comment.new(c.raw)
        end.map do |c_e| # Events
          Entities::Stackexchange::Comment.new(c_e)
            .procure
            .determine
            .group
            .normalize
            .instance
        end if @payload.comments
      end

      private

      def find_by_origin_id
        Entity
          .feed('stackexchange')
          .type('answer')
          .where(origin_id: @payload.answer_id.to_s)
          .first
      end

    end

  end
end
