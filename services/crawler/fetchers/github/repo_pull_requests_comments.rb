module Fetchers
  module Github

    class RepoPullRequestsComments
      include Protocol

      def initialize(client, opts)
        @client = client
        @user, @repo = opts.fetch(:user_repo).split('/')
      end

      def fetch
        @client.pull_requests.comments.list user: @user, repo: @repo
      end
    end
  end
end
