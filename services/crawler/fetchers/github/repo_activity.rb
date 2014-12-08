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
        @client.activity.events.repos @user, @repo
      rescue ::Github::Error::Forbidden => e
        Celluloid.logger.error "Github::RepoActivity fetcher error: #{e}"
        nil
      end
    end
  end
end
