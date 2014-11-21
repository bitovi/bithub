module Supervisors::Services::Twitter
  class UserTimeline < Supervisors::Service
    include Supervisors::Services::Twitter::Common

    def boot
      @endpoints = SupervisionGroup.new

      user_timeline_fetcher = Fetchers::Twitter::UserTimeline.new(
        client, { user_handle: user_handle })

      @endpoints.supervise_as(
        @path.child_actor_name("user_timeline_#{user_handle}"),
        Poller, *[
          @path,
          user_timeline_fetcher,
          {interval: 60}
        ])
    end
  end
end
