require_relative 'shared/github_client'

module Fetchers
  module Github

    class RepoIssuesCommentsFetcher
      include Client

      def fetch
        @client.issues_comments(@repo)
      end
    end

  end
end
