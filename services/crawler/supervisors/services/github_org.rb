require 'github_api'

module Supervisors
  module Services
    class GithubOrg < Supervisors::Service
      def boot
        @endpoints = SupervisionGroup.new

        org_fetcher = Fetchers::Github::OrgActivity.new(
          ::Github.new(oauth_token: token),
          { org_name: org_name}
        )

        @endpoints.supervise_as(
          @path.child_actor_name('endpoint_org'),
          Poller, *[
            @path,
            org_fetcher,
            {interval: 60}
          ]
        )
      end

      private

      def org_name
        service_config.fetch(:name)
      end
    end
  end
end
