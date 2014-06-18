module Events
  module Stackexchange

    class Answer < Protocol
      include Events::Stackexchange::Accessors::Standard

      def id
        answer_id
      end

      def question_id
        source_data.andand[:question_id]
      end

      def answer_id
        source_data.andand[:answer_id]
      end

      def comments
        (source_data.andand[:comments] || []).map do |c|
          Events::Stackexchange::Comment.new(c)
        end
      end

      def upvote_count
        source_data.andand[:upvote_count]
      end

      def accepted?
        source_data[:is_accepted]
      end

      def owner
        source_data.andand[:owner]
      end
    end

  end
end
