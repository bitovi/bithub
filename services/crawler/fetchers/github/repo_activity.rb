require 'github_api'

module Fetchers
  module Github

    class RepoActivity
      include Protocol

      def initialize(client, opts)
        @client = client
        @user, @repo = opts.fetch(:user_repo).split('/')
      end

      def fetch
        Celluloid.logger.info "[FETCHER] Fetching Github/RepoActivity"

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
