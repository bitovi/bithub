module Supervisors::Services::Rss
  class Site < Supervisors::Service

    def boot
      @endpoints.supervise_as(
        @path.next_level(NodeTypes::EndpointInfo.new(url)).actor_name,
        Poller, *[
          @path,
          Fetchers::Rss::Rss.new(url),
          { interval: 600, decorator: Decorators::Rss.new(service_config) }
        ])
    end

    private

    def url
      service_config.fetch(:url)
    end
  end
end
