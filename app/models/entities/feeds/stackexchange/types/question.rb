module Entities
  module Stackexchange

    class Question < Protocol
      include SharedBuilders

      def find
        @event.question_id && find_by_question_id
      end

      def data
        with_commons({
          title: @event.title,
          origin_id: @event.question_id.to_s,
          props: {
            score: @event.score,
            accepted_answer_id: @event.accepted_answer_id,
            upvote_count: @event.upvote_count,
          }
        })
      end

      def update
        @instance.title = @event.title
        @instance.body = @event.body_markdown || @event.body
        @instance.props[:score] = @event.score
        @instance.props[:upvote_count] = @event.upvote_count
        @instance.props[:accepted_answer_id] = @event.accepted_answer_id

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
        @event.answers.map do |a| # Wrappers
          Events::Stackexchange::AnswerEvent.new(a.raw)
        end.map do |a_e| # Events
          Entities::Stackexchange::Answer.new(a_e)
          .procure.determine.group.normalize.instance
        end if @event.answers
      end

      def build_comments
        @event.comments.map do |c| # Wrappers
          Events::Stackexchange::CommentEvent.new(c.raw)
        end.map do |c_e| # Events
          Entities::Stackexchange::Comment.new(c_e)
          .procure.determine.group.normalize.instance
        end if @event.comments
      end

      def update_answers
        @event.answers.map do |a| # Wrappers
          Events::Stackexchange::AnswerEvent.new(a.raw)
        end.map do |a_e| # Events
          Entities::Stackexchange::Answer.new(a_e)
          .procure.update.determine.group.normalize.persist
        end if @event.answers
      end

      def find_by_question_id
        Entity
          .feed('stackexchange')
          .type('question')
          .where(origin_id: @event.question_id.to_s)
          .first
      end

    end
  end
end
