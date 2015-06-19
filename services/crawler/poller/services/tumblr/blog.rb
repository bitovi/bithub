require 'services/intervals'

module Supervisors::Services::Tumblr
  class Blog < Supervisors::Service

    def boot
      @endpoints.supervise_as(
        @path.next_level(NodeTypes::EndpointInfo.new('blog', hostname)).actor_name,
        Poller, *[
          @path,
          Fetchers::Tumblr::Posts.new(hostname),
          { interval: TUMBLR_BLOG }
        ])
    end

    private

    def hostname
      service_config.fetch(:hostname)
    end
  end
end
