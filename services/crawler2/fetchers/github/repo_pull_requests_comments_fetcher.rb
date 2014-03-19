require_relative 'shared/github_client'

module Fetchers
  module Github

    class RepoPullRequestsCommentsFetcher
      include Client

      def fetch
        @client.pull_requests_comments(@repo)
      end
    end

  end
end
