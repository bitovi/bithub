module Supervisors::Services::Github
  class Org < Supervisors::Service
    include Supervisors::Services::Github::Common

    def initialize
      super

      @endpoints.supervise_as(
        @path.next_level(EndpointInfo.new('org_activity', org_name)).actor_name,
        Poller, *[
          @path,
          Fetchers::Github::OrgActivity.new(client, { org_name: org_name }),
          {interval: 60}
        ])
    end

    private

    def org_name
      service_config.fetch(:name)
    end
  end
end
