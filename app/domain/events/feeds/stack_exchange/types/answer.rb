module Events
  module StackExchange

    class Answer < Protocol
      extend Forwardable

      def_delegators :@answer, :answer_id, :question_id,
        :title, :body, :link, :score, :accepted?,
        :upvote_count, :last_activity_date, :creation_date

      def_delegator :@owner, :id, :origin_author_id

      attr_reader :comments, :owner

      def digest_seed
        answer_id.to_s +
          (last_activity_date || creation_date).to_s +
          self.class.name
      end

      def origin_id
        answer_id
      end

      def origin_timestamp
        creation_date.utc
      end

      def wrap_reponse_parts
        @answer = Wrappers::StackExchange::Answer.new(source_data)
        @comments = source_data[:comments].map{|c| Wrappers::StackExchange::Comment.new(c)}
        @owner = Wrappers::StackExchange::User.new(source_data[:owner])
      end
    end
  end
end
