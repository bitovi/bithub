module Events
  module Stackexchange

    class QuestionEvent < Protocol
      extend Forwardable

      def_delegators :@question, :question_id, :accepted_answer_id,
        :title, :body, :body_markdown, :link, :score, :answered?,
        :upvote_count, :last_activity_date, :creation_date

      attr_reader :question, :answers, :comments, :owner

      def digest_seed
        @question.question_id.to_s +
          (last_activity_date || creation_date).to_s +
          self.class.name
      end

      def wrap_response
        @question = Wrappers::Stackexchange::Question.new(source_data)
        @answers = source_data[:answers].andand.map{|a| Wrappers::Stackexchange::Answer.new(a)}
        @comments = source_data[:comments].andand.map{|c| Wrappers::Stackexchange::Comment.new(c)}
        @owner = Wrappers::Stackexchange::User.new(source_data[:owner])
      end
    end

  end
end
