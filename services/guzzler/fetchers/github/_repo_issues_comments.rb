require 'fetchers/protocol'

module Guzzler::Fetchers

  module Github
    class RepoIssuesComments
      include Protocol

      def initialize(client, opts)
        @client = client
        @user, @repo = opts.fetch(:user_repo).split('/')
      end

      def fetch
        Celluloid.logger.info "[FETCHER] Fetching Github/RepoIssuesComments"

        handle_errors do
          @client.issues.comments.list(user: @user, repo: @repo)
        end
      end
    end
  end
end
