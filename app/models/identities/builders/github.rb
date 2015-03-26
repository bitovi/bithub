require 'octokit'

module Identities
  module Builders
    class Github < Builder::Protocol

      def run
        repos
        orgs
        self
      end

      def repos
        if rs = repos_over_http
          @storage[:repos] = rs.map(&:to_h)
        end
      end

      def orgs
        if os = orgs_over_http
          @storage[:orgs] = os.map(&:to_h)
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
        ::Octokit::Client.new :access_token => token, :auto_paginate => true
      end

    end
  end
end
