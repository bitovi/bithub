module Events
  module StackExchange

    class Answer < Protocol
      include Events::StackExchange::Accessors::Standard

      def content_digest
        Digest::MD5.hexdigest(origin_id.to_s + (last_activity_date || origin_ts).to_s + self.class.name)
      end

      def origin_id
        answer_id
      end

      def answer_id
        source_data.andand[:answer_id].to_s
      end

      def question_id
        source_data.andand[:question_id].to_s
      end

      def title
        source_data.andand[:title]
      end

      def accepted?
        source_data.andand[:is_accepted]
      end

      def upvote_count
        source_data.andand[:up_vote_count]
      end

      def comments
        @comments ||= source_data[:comments].to_a.map {|c| Events::StackExchange::Comment.new(c)}
      end

      # def comment_messages
      #   comments.map(&:message)
      # end

    end

  end
end
