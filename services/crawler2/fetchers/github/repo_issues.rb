require 'github_api'

module Fetchers
  module Github

    class RepoIssues
      def initialize(cfg)
        @config = cfg
        @client = ::Github.new oauth_token: @config.fetch(:token)
      end

      def fetch
        @client.issues.list user: @config.fetch(:user), repo: @config.fetch(:repo)
      end
    end

  end
end
