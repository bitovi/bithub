module Wrappers
  module StackExchange

    class Question
      include DataAccessible
      include CoreHelpers

      has :question_id,
        :title, :body, :body_markdown, :link, :score,
        :is_answered, :up_vote_count

      maybe_has :accepted_answer_id

      alias_method :answered?, :is_answered
      alias_method :upvote_count, :up_vote_count

      attr_reader :answers, :comments, :owner

      def initialize(question)
        @data = symbolize_keys(question)
      end
      
      def creation_date
        Time.at(@data.fetch(:creation_date)).utc
      end

      def last_activity_date
        Time.at(@data.fetch(:last_activity_date)).utc
      end

      def last_edit_date
        Time.at(@data.fetch(:last_edit_date)).utc
      end

    end
  end
end
