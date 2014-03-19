require_relative 'shared/github_client'

module Fetchers
  module Github

    class GithubRepoPullRequestsFetcher
      include Client

      def fetch
        @client.pull_requests(@repo)
      end
    end

  end
end
