module Fetchers
  module Github

    class RepoPullRequestsComments
      include Protocol

      def initialize(client, opts)
        ::NewRelic::Agent.increment_metric('Custom/Fetches/Github/repo_pull_req_comments')
        @client = client
        @user, @repo = opts.fetch(:user_repo).split('/')
      end

      def fetch
        handle_errors do
          @client.pull_requests.comments.list(user: @user, repo: @repo)
        end
      end
    end
  end
end
