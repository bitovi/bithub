require_relative 'shared/github_client'

module Fetchers
  module Github

    class RepoIssuesFetcher
      include Client

      def fetch
        @client.list_issues(@repo)
      end
    end

  end
end
