require_relative 'shared/issue_like'

module Wrappers
  module Github

    class Issue
      include CoreHelpers
      include IssueLike

      attr_reader :user, :labels

      def initialize(issue)
        @i = symbolize_keys(issue)
        @user = Wrappers::Github::User.new(issue.andand[:user])
        @labels = Wrappers::Github::Labels.new(issue.andand[:labels])
      end

      def references_to
        Reference.scan_for_refs(body)
      end
    end

  end
end
