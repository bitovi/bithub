require 'github_api'

module Fetchers
  module Github

    class RepoActivity
      include Protocol

      def initialize(client, opts)
        ::NewRelic::Agent.increment_metric('Custom/Fetches/Github/repo_activity')
        @client = client
        @user, @repo = opts.fetch(:user_repo).split('/')
      end

      def fetch
        handle_errors do
          @client.activity.events.auto_pagination = false
          @client.activity.events.repos(user: @user, repo: @repo)
        end
      end

      def initial_fetch
        handle_errors do
          @client.activity.events.auto_pagination = true
          @client.activity.events.repos(user: @user, repo: @repo)
        end
      end
    end
  end
end
