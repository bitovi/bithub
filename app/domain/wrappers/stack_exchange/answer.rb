module Wrappers
  module StackExchange

    class Answer
      include DataAccessible
      include CoreHelpers

      has :answer_id, :question_id,
        :title, :body, :link, :score, :is_accepted,
        :up_vote_count
      
      maybe_has :rsvp_count, :body_markdown

      alias_method :accepted?, :is_accepted
      alias_method :upvote_count, :up_vote_count

      attr_reader :comments, :owner

      def initialize(answer)
        @data = symbolize_keys(answer)
      end

      def creation_date
        Time.at(@data.fetch(:creation_date)).utc
      end

      def last_activity_date
        Time.at(@data.fetch(:last_activity_date)).utc
      end

    end
  end
end
