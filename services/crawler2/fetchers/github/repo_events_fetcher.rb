require_relative 'shared/github_client'

module Fetchers
  module Github

    class RepoEventsFetcher
      include Client

      def fetch
        @client.repository_events(@repo)
      end
    end

  end
end
