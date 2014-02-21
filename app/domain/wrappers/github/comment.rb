module Wrappers
  module Github

    class Comment
      include CoreHelpers

      def initialize(comment)
        @c = symbolize_keys(comment)
      end

      def raw
        @c
      end

      def id
        @c.andand[:id]
      end

      def body
        @c.andand[:body]
      end

      def html_url
        @c.andand[:html_url]
      end

      def commit_id
        @c.andand[:commit_id]
      end

      def references_to
        Reference.scan_for_refs(body)
      end
    end

  end
end
