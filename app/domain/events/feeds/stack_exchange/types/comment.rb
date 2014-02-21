module Events
  module StackExchange

    class Comment < Protocol
      include Events::StackExchange::Accessors::Standard

      def content_digest
        Digest::MD5.hexdigest(self.class.name)
      end

      def origin_id
        comment_id
      end

      def post_id
        source_data.andand[:post_id]
      end

      def comment_id
        source_data.andand[:comment_id]
      end

    end

  end
end
