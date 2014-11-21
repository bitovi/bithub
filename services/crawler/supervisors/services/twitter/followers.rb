module Supervisors::Services::Twitter
  class Followers < Supervisors::Service
    include Supervisors::Services::Twitter::Common

    def boot
      @endpoints = SupervisionGroup.new

      user_timeline_fetcher = Fetchers::Twitter::Followers.new(client)

      @endpoints.supervise_as(
        @path.child_actor_name("followers_dodaj_user_handle_auth"),
        Poller, *[
          @path,
          user_timeline_fetcher,
          {interval: 60}
        ])
    end
  end
end
