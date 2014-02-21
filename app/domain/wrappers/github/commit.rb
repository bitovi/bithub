module Wrappers
  module Github

    class Commit
      include CoreHelpers

      def initialize(commit)
        @c = symbolize_keys(commit)
      end

      def sha
        @c[:sha]
      end

      def message
        @c[:message]
      end

      def url
        @c[:url]
      end

      def author_name
        @c[:author].andand[:name]
      end

      def author_email
        @c[:author].andand[:email]
      end

      def references_to
        @refs ||= Reference.scan_for_refs(message)
      end

    end

  end
end
