require_relative 'client'

module Fetchers
  module Github

    class RepoIssues
      include Client

      def fetch
        @client.list_issues(@repo)
      end
    end

  end
end
