module Events
  module StackExchange

    class Question < Protocol
      extend Forwardable

      def_delegators :@question, :question_id, :accepted_answer_id,
        :title, :body, :link, :score, :answered?,
        :upvote_count, :last_activity_date, :creation_date

      def digest_seed
        question_id.to_s +
          (last_activity_date || creation_date).to_s +
          self.class.name
      end

      def origin_id
        question_id
      end

      def origin_timestamp
        creation_date.utc
      end

      def wrap_reponse_parts
        @question = Wrappers::StackExchange::Question.new(source_data)
        @answers = @question.answers
        @comments = @question.comments
        @owner = @question.owner
      end

    end

  end
end
