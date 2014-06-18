module Events
  module Stackexchange

    class Comment < Protocol
      include Events::Stackexchange::Accessors::Standard

      def id
        comment_id
      end

      def post_type
        source_data.andand[:post_type]
      end

      def post_id
        source_data.andand[:post_id]
      end

      def comment_id
        source_data.andand[:comment_id]
      end

      def owner
        source_data.andand[:owner]
      end
    end

  end
end
