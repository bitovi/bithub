module FeedSupervisors
  class Rss
    include Celluloid

    def initialize(brand_name)
      @brand_name = brand_name

      boot
    end

    def boot
      Celluloid.logger.info "Booting RSS supervisor for #{@brand_name}"
      @endpoints = SupervisionGroup.new

      urls.each do |url|
        @endpoints.supervise_as \
          actor_name(url),
          Poller,
          *[@brand_name, Fetchers::Rss::Rss.new(url), {interval: 300}]
      end

    end

    private

    def config
      Celluloid::Actor[:configurator].feed_config(@brand_name, :rss)
    end

    def urls
      config.fetch(:urls)
    end

    def actor_name(url)
      "#{@brand_name}_rss_#{url}".to_sym
    end

  end
end
