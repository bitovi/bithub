module Fetchers
  module Github

    class RepoIssues
      include Protocol

      def initialize(client, opts)
        @client = client
        @user, @repo = opts.fetch(:user_repo).split('/')
      end

      def fetch
        Celluloid.logger.info "[FETCHER] Fetching Github/RepoIssues"

        handle_errors do
          @client.issues.list(user: @user, repo: @repo)
        end
      end
    end
  end
end
