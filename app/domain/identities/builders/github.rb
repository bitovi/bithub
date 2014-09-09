require 'octokit'

module Identities
  module Builders
    class Github < Base

      def initialize(args)
        super
        @conn = create_github_client
        self
      end

      def build
        sync_repos
        sync_orgs
        @data
      end

      def sync_repos
        @data[:repos] = fetch_repos
      end

      def sync_orgs
        @data[:orgs] = fetch_orgs
      end

      # Accessors

      def access_token
        oauth.fetch(:credentials).fetch(:token)
      end

      def repo_names
        repos.map {|r| r[:full_name]}
      end

      def org_names
        orgs.map {|o| o[:login]}
      end

      def repos
        @data.fetch(:repos)
      end

      def orgs
        @data.fetch(:orgs)
      end

      private

      def fetch_repos
        # org repos aren't included in response
        @conn.repos
      end

      def fetch_orgs
        @conn.orgs
      end

      def create_github_client
        ::Octokit::Client.new \
        :access_token => access_token,
        :auto_paginate => true
      end

    end
  end
end
