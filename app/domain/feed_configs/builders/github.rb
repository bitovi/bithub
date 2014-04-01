module FeedConfigs
  module Builders
    class Github < Base

      def initialize(args)
        super args do
          @conn = create_github_client
        end
      end

      def build
        {
          token: access_token,
          repos: fetch_repos,
          orgs: fetch_orgs
        }
      end

      def fetch_repos
        # org repos aren't included in response
        @conn.repos.map {|r| r.full_name}
      end

      def fetch_orgs
        @conn.orgs.map {|o| o.login}
      end

      private

      def access_token
        @oauth_data.fetch(:credentials).fetch(:token)
      end

      def create_github_client
        Octokit::Client.new \
        :access_token => access_token,
        :auto_paginate => true
      end

    end
  end
end
