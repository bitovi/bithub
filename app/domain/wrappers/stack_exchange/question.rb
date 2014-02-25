module Wrappers
  module StackExchange

    class Question
      extend DataAccessible
      include CoreHelpers

      has :question_id, :accepted_answer_id,
        :title, :body, :link, :score, :is_answered,
        :up_vote_count, :body_markdown

      alias_method :answered?, :is_answered
      alias_method :upvote_count, :up_vote_count

      attr_reader :answers, :comments, :owner

      def initialize(question)
        @data = symbolize_keys(question)
        @answers = @data[:answers].andand.map{|a| Wrappers::StackExchange::Answer.new(a)}
        @comments = @data[:comments].andand.map{|c| Wrappers::StackExchange::Comment.new(c)}
        @owner = Wrappers::StackExchange::User.new(@data[:owner])
      end
      
      def creation_date
        Time.at @data[:creation_date]
      end

      def last_activity_date
        Time.at @data[:last_activity_date]
      end

      def last_edit_date
        Time.at @data[:last_edit_date]
      end

    end
  end
end
