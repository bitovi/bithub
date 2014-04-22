module Fetchers
  module Github

    class RepoPullRequests
      include Protocol

      def initialize(client, opts)
        @client = client
        @user, @repo = opts.fetch(:user_repo).split('/')
      end

      def fetch
        @client.activity.events.public user: @user, repo: @repo
      end
    end
  end
end
