module Wrappers
  module StackExchange

    class Answer
      extend DataAccessible
      include CoreHelpers

      data_accessors :answer_id, :question_id,
        :title, :body, :score, :link,
        :is_accepted, :up_vote_count,
        :body_markdown

      alias_method :accepted?, :is_accepted
      alias_method :upvote_count, :up_vote_count

      def initialize(answer)
        @data = symbolize_keys(answer)
        @comments = @data[:comments].andand.map{|c| Wrappers::StackExchange::Comment.new(c)}
        @owner = Wrappers::StackExchange::User.new(@data.andand[:answer])
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
