module Wrappers
  module StackExchange

    class Answer
      extend DataAccessible
      include CoreHelpers

      has :answer_id, :question_id,
        :title, :body, :link, :score, :is_accepted,
        :up_vote_count, :body_markdown

      alias_method :accepted?, :is_accepted
      alias_method :upvote_count, :up_vote_count

      attr_reader :comments, :owner

      def initialize(answer)
        @data = symbolize_keys(answer)
      end

      def creation_date
        Time.at(@data[:creation_date])
      end

      def last_activity_date
        Time.at(@data[:last_activity_date])
      end

    end
  end
end
