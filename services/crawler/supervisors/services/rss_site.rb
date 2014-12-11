module Supervisors::Services::Rss
  class Site < Supervisors::Service
    def boot
      @endpoints = SupervisionGroup.new

      decorator = Decorators::Rss.new(service_config)
      rss_fetcher = Fetchers::Rss::Rss.new(url)

      @endpoints.supervise_as(
        @path.next_level(EndpointInfo.new(url)).actor_name,
        Poller, *[
          @path,
          rss_fetcher,
          {interval: 300, decorator: decorator}
        ])
    end

    private

    def url
      service_config.fetch(:url)
    end
  end
end
