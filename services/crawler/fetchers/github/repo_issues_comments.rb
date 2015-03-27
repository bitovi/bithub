require 'fetchers/protocol'

module Fetchers
  module Github

    class RepoIssuesComments
      include Protocol

      def initialize(client, opts)
        ::NewRelic::Agent.increment_metric('Custom/Fetches/Github/repo_issue_comments')
        @client = client
        @user, @repo = opts.fetch(:user_repo).split('/')
      end

      def fetch
        handle_errors do
          @client.issues.comments.list(user: @user, repo: @repo)
        end
      end
    end
  end
end
