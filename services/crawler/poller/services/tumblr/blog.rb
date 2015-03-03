module Supervisors::Services::Tumblr
  class Blog < Supervisors::Service

    def initialize(path, service_info)
      super

      @endpoints.supervise_as(
        @path.next_level(NodeTypes::EndpointInfo.new('blog', hostname)).actor_name,
        Poller, *[
          @path,
          Fetchers::Tumblr::Posts.new(hostname),
          { interval: 600 }
        ])
    end

    private

    def hostname
      service_config.fetch(:hostname)
    end
  end
end
