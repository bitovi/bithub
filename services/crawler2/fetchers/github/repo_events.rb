require_relative 'client'

module Fetchers
  module Github

    class RepoEvents
      include Client

      def fetch
        @client.repository_events(@repo)
      end
    end

  end
end
