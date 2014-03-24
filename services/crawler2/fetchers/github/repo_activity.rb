require 'github_api'

module Fetchers
  module Github

    class RepoActivity
      def initialize(cfg)
        @config = cfg
        @client = ::Github.new oauth_token: @config.fetch(:token)
      end

      def fetch
        @client.activity.events.public user: @config.fetch(:user), repo: @config.fetch(:repo)
      end
    end

  end
end
