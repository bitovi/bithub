require_relative 'shared/issue_like'

module Wrappers
  module Github

    class Issue
      include DataAccessible
      include CoreHelpers
      include IssueLike

      attr_reader :user, :labels

      def initialize(issue)
        @i = symbolize_keys(issue)
        @user = Wrappers::Github::User.new(issue[:user])
        @labels = Wrappers::Github::Labels.new(issue[:labels])
      end

      def references_to
        Reference.scan_for_refs(body)
      end
    end

  end
end
