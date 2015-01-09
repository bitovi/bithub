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
        handle_errors do
          @client.activity.events.repos @user, @repo
        end
      end
    end
  end
end
