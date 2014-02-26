module Events
  module StackExchange

    class Question < Protocol
      extend Forwardable

      def_delegators :@question, :question_id, :accepted_answer_id,
        :title, :body, :link, :score, :answered?,
        :upvote_count, :last_activity_date, :creation_date

      def_delegator :@owner, :id, :owner_id
      def_delegator :@owner, :display_name, :owner_name
      def_delegator :@owner, :profile_image, :owner_profile_image

      attr_reader :question, :answers, :comments, :owner

      def digest_seed
        question_id.to_s +
          (last_activity_date || creation_date).to_s +
          self.class.name
      end

      def origin_id
        question_id
      end

      def origin_timestamp
        creation_date.utc
      end

      def wrap_reponse
        @question = Wrappers::StackExchange::Question.new(source_data)
        @answers = source_data[:answers].map{|a| Wrappers::StackExchange::Answer.new(a)}
        @comments = source_data[:comments].map{|c| Wrappers::StackExchange::Comment.new(c)}
        @owner = Wrappers::StackExchange::User.new(source_data[:owner])
      end

      alias_method :origin_author_id, :owner_id
      alias_method :origin_author_name, :owner_name
      alias_method :origin_author_avatar_url, :owner_profile_image
    end

  end
end
