module Events
  module StackExchange

    class Comment < Protocol
      extend Forwardable
      
      def_delegators :@comment, :comment_id, :post_id, :post_type,
        :body, :link, :score, :edited?,
        :creation_date

      def digest_seed
        comment_id.to_s + creation_date.to_s + self.class.name
      end

      def origin_id
        comment_id
      end

      def origin_timestamp
        creation_date.utc
      end

      def wrap_reponse_parts
        @comment = Wrappers::StackExchange::Comment.new(source_data)
      end

    end

  end
end
