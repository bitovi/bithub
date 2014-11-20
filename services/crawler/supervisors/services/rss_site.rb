module Supervisors
  module Services
    class RssSite < Supervisors::Service
      def boot
        @endpoints = SupervisionGroup.new

        decorator = Decorators::Rss.new(service_config)
        rss_fetcher = Fetchers::Rss::Rss.new(url)

        @endpoints.supervise_as(
          @path.child_actor_name(url),
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
end
