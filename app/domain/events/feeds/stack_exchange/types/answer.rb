module Events
  module StackExchange

    class Answer < Protocol
      include Events::StackExchange::Accessors::Standard

      def content_digest
        Digest::MD5.hexdigest(origin_id.to_s + (last_edit_date || origin_ts).to_s + self.class.name)
      end

      def origin_id
        answer_id
      end

      def answer_id
        source_data.andand[:answer_id]
      end

      def question_id
        source_data.andand[:question_id]
      end

      def title
        source_data.andand[:title]
      end

      def accepted?
        source_data.andand[:is_accepted]
      end

      def comments
        @comments ||= source_data[:comments].map {|c| Events::StackExchange::Comment.new(c)}
      end

      # def comment_messages
      #   comments.map(&:message)
      # end

    end

  end
end
