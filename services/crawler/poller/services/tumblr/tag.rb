require 'services/intervals'

module Supervisors::Services::Tumblr
  class Tag < Supervisors::Service

    def boot
      @endpoints.supervise_as(
        @path.next_level(NodeTypes::EndpointInfo.new('tagged', tag)).actor_name,
        Poller, *[
          @path,
          Fetchers::Tumblr::Tagged.new(tag),
          { interval: TUMBLR_TAG }
        ])
    end

    private

    def tag
      service_config.fetch(:tag)
    end
  end
end
