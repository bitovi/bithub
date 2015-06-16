module Supervisors::Services::Twitter
  class UserRetweets < Supervisors::Service
    include Supervisors::Services::Twitter::Common

    def boot
      @endpoints.supervise_as(
        @path.next_level(NodeTypes::EndpointInfo.new('user_timeline', user_handle)).actor_name,
        Poller, *[
          @path,
          Fetchers::Twitter::UserRetweets.new(client, { user_handle: user_handle }),
          {interval: 300}
        ])
    end
  end
end
