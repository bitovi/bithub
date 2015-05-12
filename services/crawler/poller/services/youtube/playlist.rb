require 'google/api_client'

module Supervisors::Services::Youtube
  class Playlist < Supervisors::Service
    include Common

    def boot
      @endpoints.supervise_as(
        @path.next_level(NodeTypes::EndpointInfo.new('playlist', target_id)).actor_name,
        Poller, *[
          @path,
          Fetchers::Youtube::PlaylistVideos.new(client, { playlist_id: target_id }),
          {interval: 900}
        ])
    end

  end
end
