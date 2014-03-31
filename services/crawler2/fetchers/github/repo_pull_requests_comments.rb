require 'github_api'

module Fetchers
  module Github

    class RepoPullRequestsComments
      def initialize(token, user_repo)
        @user, @repo = user_repo.split('/')
        @client = ::Github.new oauth_token: token
      end

      def fetch
        @client.activity.events.public user: @user, repo: @repo
      end

      def default_interval
        250
      end
    end

  end
end
