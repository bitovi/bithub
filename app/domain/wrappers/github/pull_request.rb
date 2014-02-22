require_relative 'shared/issue_like'

module Wrappers
  module Github

    class PullRequest
      include CoreHelpers
      include IssueLike

      attr_reader :user

      def initialize(pull_req)
        @pr = symbolize_keys(pull_req)
        @user = Wrappers::Github::User.new(pull_req.andand[:user])
      end

      def references_to
        Reference.scan_for_refs(body)
      end
    end

  end
end
