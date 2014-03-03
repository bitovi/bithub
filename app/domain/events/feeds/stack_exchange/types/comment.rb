module Events
  module StackExchange

    class Comment < Protocol
      extend Forwardable
      
      def_delegators :@comment, :comment_id, :post_id, :post_type,
        :body, :link, :score, :edited?, :creation_date

      def digest_seed
        @comment.comment_id.to_s + creation_date.to_s + self.class.name
      end

      def wrap_response
        @comment = Wrappers::StackExchange::Comment.new(source_data)
        @owner = Wrappers::StackExchange::User.new(source_data[:owner])
        self
      end

    end

  end
end
