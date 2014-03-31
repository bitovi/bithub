require 'github_api'

module Fetchers
  module Github

    class RepoPullRequestsComments
      def initialize(client, opts)
        @client = client
        @interval = opts.fetch(:interval) { 10 }
        @user, @repo = opts.fetch(:user_repo).split('/')
      end
      attr_reader :interval

      def fetch
        @client.activity.events.public user: @user, repo: @repo
      end
    end

  end
end
