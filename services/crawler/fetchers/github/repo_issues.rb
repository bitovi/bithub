module Fetchers
  module Github

    class RepoIssues
      include Protocol

      def initialize(client, opts)
        ::NewRelic::Agent.increment_metric('Custom/Fetches/Github/repo_issues')
        @client = client
        @user, @repo = opts.fetch(:user_repo).split('/')
      end

      def fetch
        handle_errors do
          @client.issues.list(user: @user, repo: @repo)
        end
      end
    end
  end
end
