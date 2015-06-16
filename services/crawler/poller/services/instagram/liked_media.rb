module Supervisors::Services::Instagram
  class LikedMedia < Supervisors::Service

    def boot
      @endpoints.supervise_as(
        @path.next_level(NodeTypes::EndpointInfo.new('liked_media', '')).actor_name,
        Poller, *[
          @path,
          Fetchers::Instagram::UserLikedMedia.new({ access_token: access_token }),
          { interval: 300 }
        ])
    end

    private

    def access_token
      service_config.fetch(:access_token)
    end

  end
end
