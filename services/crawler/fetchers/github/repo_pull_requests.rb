module Fetchers
  module Github

    class RepoPullRequests
      include Protocol

      def initialize(client, opts)
        @client = client
        @user, @repo = opts.fetch(:user_repo).split('/')
      end

      def fetch
        @client.pull_requests.list user: @user, repo: @repo
      end
    end
  end
end
