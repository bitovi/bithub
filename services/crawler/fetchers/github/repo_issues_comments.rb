module Fetchers
  module Github

    class RepoIssuesComments
      include Protocol

      def initialize(client, opts)
        @client = client
        @user, @repo = opts.fetch(:user_repo).split('/')
      end

      def fetch
        @client.issues.commments.list user: @user, repo: @repo
      end
    end
  end
end
