require_relative 'shared/issue_like'

module Wrappers
  module Github

    class PullRequest
      include DataAccessible
      include CoreHelpers
      include IssueLike

      attr_reader :user

      def initialize(pull_req)
        @pr = symbolize_keys(pull_req)
        @user = Wrappers::Github::User.new(@pr.andand[:user])
      end

      def labels
        @labels ||= Wrappers::Github::Labels.new([])
      end

      def references_to
        Reference.scan_for_refs(body)
      end
    end

  end
end
