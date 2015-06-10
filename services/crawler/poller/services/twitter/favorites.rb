module Supervisors::Services::Twitter
  class Favorites < Supervisors::Service
    include Supervisors::Services::Twitter::Common

    def boot
      @endpoints.supervise_as(
        @path.next_level(NodeTypes::EndpointInfo.new("favorites", user_handle)).actor_name,
        Poller, *[
          @path,
          Fetchers::Twitter::Favorites.new(client, { user_handle: user_handle }),
          {interval: 300}
        ])
    end
  end
end
