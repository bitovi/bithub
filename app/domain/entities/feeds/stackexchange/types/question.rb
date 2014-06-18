module Entities
  module Stackexchange

    class Question < Protocol

      def find
        @payload.question_id && find_by_question_id
      end

      def build
        Entity.new({
          title: @payload.title,
          body: @payload.body_markdown || @payload.body,
          url: @payload.link,
          origin_ts: @payload.creation_date,
          origin_id: @payload.question_id.to_s,
          props: {
            origin_author_id: @payload.origin_author_id,
            origin_author_name: @payload.origin_author_name,
            origin_author_avatar_url: @payload.origin_author_avatar_url,
            score: @payload.score,
            accepted_answer_id: @payload.accepted_answer_id,
            upvote_count: @payload.upvote_count,
          }
        })
      end

      def update
        @instance.title = @payload.title
        @instance.body = @payload.body_markdown || @payload.body
        @instance.props[:score] = @payload.score
        @instance.props[:upvote_count] = @payload.upvote_count
        @instance.props[:accepted_answer_id] = @payload.accepted_answer_id

        # ?!?!
        update_children
        self
      end

      def build_children
        build_comments.to_a + build_answers.to_a
      end

      def update_children
        update_answers
      end

      private

      def build_answers
        @payload.answers.map do |a| # Wrappers
          Events::Stackexchange::Answer.new(a.raw)
        end.map do |a_e| # Events
          Entities::Stackexchange::Answer.new(a_e)
          .procure.determine.group.normalize.instance
        end if @payload.answers
      end

      def build_comments
        @payload.comments.map do |c| # Wrappers
          Events::Stackexchange::Comment.new(c.raw)
        end.map do |c_e| # Events
          Entities::Stackexchange::Comment.new(c_e)
          .procure.determine.group.normalize.instance
        end if @payload.comments
      end

      def update_answers
        @payload.answers.map do |a| # Wrappers
          Events::Stackexchange::Answer.new(a.raw)
        end.map do |a_e| # Events
          Entities::Stackexchange::Answer.new(a_e)
          .procure.update.determine.group.normalize.persist
        end if @payload.answers
      end

      def find_by_question_id
        Entity
          .feed('stackexchange')
          .type('question')
          .where(origin_id: @payload.question_id.to_s)
          .first
      end

    end
  end
end
