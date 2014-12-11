module Supervisors::Services::Github
  class Org < Supervisors::Service
    include Supervisors::Services::Github::Common

    def boot
      @endpoints = SupervisionGroup.new

      org_fetcher = Fetchers::Github::OrgActivity.new(
        client, { org_name: org_name })

      @endpoints.supervise_as(
        @path.next_level(EndpointInfo.new('org_' + org_name)).actor_name,
        Poller, *[
          @path,
          org_fetcher,
          {interval: 60}
        ])
    end

    private

    def org_name
      service_config.fetch(:name)
    end
  end
end
