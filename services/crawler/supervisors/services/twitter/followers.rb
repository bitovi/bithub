module Supervisors::Services::Twitter
  class Followers < Supervisors::Service
    include Supervisors::Services::Twitter::Common

    def boot
      super
      @endpoints = SupervisionGroup.new

      user_timeline_fetcher = Fetchers::Twitter::Followers.new(client)

      @endpoints.supervise_as(
        @path.next_level(EndpointInfo.new('followers', user_handle)).actor_name,
        Poller, *[
          @path,
          user_timeline_fetcher,
          {interval: 60}
        ])
    end
  end
end
