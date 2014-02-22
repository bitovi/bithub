require_relative 'shared/issue_like'

module Wrappers
  module Github

    class Issue
      include CoreHelpers
      include IssueLike

      attr_reader :user

      def initialize(issue)
        @i = symbolize_keys(issue)
        @user = Wrappers::Github::Actor.new(issue.andand[:user])
        @labels = Wrappers::Github::Labels(issue.andand[:labels])
      end

      def raw
        @i
      end

      def references_to
        Reference.scan_for_refs(body)
      end
    end

  end
end
