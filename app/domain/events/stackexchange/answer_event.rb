module Events
  module Stackexchange

    class AnswerEvent < Protocol
      extend Forwardable

      def_delegators :@answer, :answer_id, :question_id,
        :title, :body, :body_markdown, :link, :score, :accepted?,
        :upvote_count, :last_activity_date, :creation_date

      def_delegator :@owner, :id, :origin_author_id

      attr_reader :comments, :owner

      def digest_seed
        @answer.answer_id.to_s\
          + (last_activity_date || creation_date).to_s\
          + self.class.name
      end

      def wrap_response
        @answer = Wrappers::Stackexchange::Answer.new(source_data)
        @owner = Wrappers::Stackexchange::User.new(source_data[:owner])
        @comments = source_data[:comments].andand.map{|c| Wrappers::Stackexchange::Comment.new(c)}
        self
      end
    end
  end
end
