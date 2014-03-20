require_relative 'client'

module Fetchers
  module Github

    class RepoPullRequests
      include Client

      def fetch
        @client.pull_requests(@repo)
      end
    end

  end
end
