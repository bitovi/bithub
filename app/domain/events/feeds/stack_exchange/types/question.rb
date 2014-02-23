module Events
  module StackExchange

    class Question < Protocol
      include Events::StackExchange::Accessors::Standard

      def content_digest
        Digest::MD5.hexdigest(origin_id.to_s + (last_edit_date || origin_ts).to_s  + self.class.name)
      end

      def origin_id
        question_id
      end

      def question_id
        source_data.andand[:question_id]
      end

      def title
        source_data.andand[:title]
      end

      def answered?
        source_data.andand[:is_answered]
      end

      def accepted_answer_id
        source_data.andand[:accepted_answer_id]
      end

      def upvote_count
        source_data.andand[:up_vote_count]
      end

      def comments
        @comments ||= source_data[:comments].map {|c| Events::StackExchange::Comment.new(c)}
      end

      def answers
        @answers ||= source_data[:answers].map {|a| Events::StackExchange::Answe.new(a)}
      end

    end

  end
end
