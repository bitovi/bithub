require 'google/api_client'

module Supervisors::Services::Youtube
  class Channel < Supervisors::Service
    include Common

    def boot
      @endpoints.supervise_as(
        @path.next_level(NodeTypes::EndpointInfo.new('channel', target_id)).actor_name,
        Poller, *[
          @path,
          Fetchers::Youtube::ChannelVideos.new(client, { channel_id: target_id }),
          { interval: YOUTUBE_CHANNEL }
        ])
    end

  end
end
