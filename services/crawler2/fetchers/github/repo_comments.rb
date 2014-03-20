require_relative 'client'

module Fetchers
  module Github

    class RepoComments
      include Client

      def fetch
        @client.issues_comments(@repo)
      end
    end

  end
end
