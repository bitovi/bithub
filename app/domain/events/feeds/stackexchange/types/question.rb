module Events
  module Stackexchange

    class Question < Protocol
      include Events::Stackexchange::Accessors::Standard

      def id
        question_id
      end

      def question_id
        source_data.andand[:question_id]
      end

      def answers
        (source_data.andand[:answers] || []).map do |a|
          Events::Stackexchange::Answer.new(a)
        end
      end

      def comments
        (source_data.andand[:comments] || []).map do |c|
          Events::Stackexchange::Comment.new(c)
        end
      end

      def accepted_answer_id
        source_data.andand[:accepted_answer_id]
      end

      def upvote_count
        source_data.andand[:upvote_count]
      end

      def owner
        source_data.andand[:owner]
      end
    end

  end
end
