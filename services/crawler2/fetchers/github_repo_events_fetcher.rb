require_relative 'shared/github_client'

module Fetchers
  module Github

    class GithubRepoEventsFetcher
      include GithubClient

      def fetch
        @client.repository_events(@repo)
      end
    end

  end
end
