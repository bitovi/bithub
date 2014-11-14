module Supervisors::Services
  class Rss < Supervisors::Service
    def boot
      @endpoints = SupervisionGroup.new

      sites.each do |site|
        if url = site[:url]
          decorator = Decorators::Rss.new site
          rss_fetcher = Fetchers::Rss::Rss.new(url)
          @endpoints.supervise_as \
            actor_name(url),
            Poller, *[
              @brand_name,
              @embed_name,
              rss_fetcher,
              {interval: 300, decorator: decorator}
            ]
        end
      end
    end

    private

    def sites
      service_config.fetch(:sites)
    end

    def actor_name(url)
      "#{@brand_name}_rss_#{url}".to_sym
    end

  end
end
