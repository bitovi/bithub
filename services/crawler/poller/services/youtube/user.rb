require 'google/api_client'

module Supervisors::Services::Youtube
  class User < Supervisors::Service
    include Common

    def boot
      @endpoints.supervise_as(
        @path.next_level(NodeTypes::EndpointInfo.new('user')).actor_name,
        Poller, *[
          @path,
          Fetchers::Youtube::UserVideos.new(client),
          {interval: 900}
        ])
    end

  end
end
