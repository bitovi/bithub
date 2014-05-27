module Events
  module Stackexchange

    class Comment < Protocol
      extend Forwardable
      
      def_delegators :@comment, :comment_id, :post_id, :post_type,
        :body, :body_markdown, :link, :score, :edited?, :creation_date

      attr_reader :owner

      def digest_seed
        @comment.comment_id.to_s + creation_date.to_s + self.class.name
      end

      def wrap_response
        @comment = Wrappers::Stackexchange::Comment.new(source_data)
        @owner = Wrappers::Stackexchange::User.new(source_data[:owner])
        self
      end

    end

  end
end
