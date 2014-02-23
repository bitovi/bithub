module Events
  module StackExchange

    class Comment < Protocol
      include Events::StackExchange::Accessors::Standard

      def content_digest
        Digest::MD5.hexdigest(origin_id.to_s + origin_ts.to_s + self.class.name)
      end

      def origin_id
        comment_id
      end

      def post_id
        source_data.andand[:post_id].to_s
      end

      def post_type
        source_data.andand[:post_type]
      end

      def comment_id
        source_data.andand[:comment_id].to_s
      end

    end

  end
end
