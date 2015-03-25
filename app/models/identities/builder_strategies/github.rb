require 'octokit'

module Identities
  module BuilderStrategies
    class Github < Protocol

      def run
        extract_credentials
        fetch_repos
        fetch_orgs
      end

      def fetch_repos
        if (repos = repos_over_http)
          @result[:repos] = repos.map(&:to_h)
        end
      end

      def fetch_orgs
        if (orgs = orgs_over_http)
          @result[:orgs] = orgs.map(&:to_h)
        end
      end

      private
      def repos_over_http
        # org repos aren't included in response
        github_client.repos
      end

      def orgs_over_http
        github_client.orgs
      end

      def github_client
        ::Octokit::Client.new \
          :access_token => @source_data.fetch(:credentials).fetch(:token),
          :auto_paginate => true
      end
    end
  end
end
