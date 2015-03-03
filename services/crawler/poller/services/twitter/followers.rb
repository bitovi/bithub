module Supervisors::Services::Twitter
  class Followers < Supervisors::Service
    include Supervisors::Services::Twitter::Common

    def initialize(path, service_info)
      super

      @endpoints.supervise_as(
        @path.next_level(NodeTypes::EndpointInfo.new('followers', user_handle)).actor_name,
        Poller, *[
          @path,
          Fetchers::Twitter::Followers.new(client, {user_handle: user_handle}),
          {interval: 600}
        ])
    end
  end
end
