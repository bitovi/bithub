require 'github_api'

module Fetchers
  module Github

    class RepoActivity
      def initialize(client, user_repo)
        @client = client
        @user, @repo = user_repo.split('/')
      end

      def fetch
        @client.activity.events.public user: @user, repo: @repo
      end

      def default_interval
        10
      end
    end

  end
end
