module Wrappers
  module Github

    class Commit
      extend DataAccessible
      include CoreHelpers

      has :sha, :message, :url

      def initialize(commit)
        @data = symbolize_keys(commit)
      end

      def ==(other)
        sha == other.sha
      end

      def author_name
        @data[:author].andand[:name]
      end

      def author_email
        @data[:author].andand[:email]
      end

      def references_to
        @refs ||= Reference.scan_for_refs(message)
      end

    end

  end
end
