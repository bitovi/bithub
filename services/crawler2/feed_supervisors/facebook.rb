require 'koala'

module FeedSupervisors
  class Facebook
    include Celluloid

    def initialize(brand_name, cfg)
      @brand_name = brand_name
      @config = cfg
      boot
    end

    def boot
      Celluloid.logger.info "Booting Facebook supervisor for #{@brand_name}"
      @endpoints = SupervisionGroup.new
      @config.fetch(:pages).each do |page|
        fetcher = Fetchers::Facebook::PageFeed.new(client = ::Koala::Facebook::API.new(page.fetch(:token)))
        @endpoints.supervise_as(actor_name('pages', page.fetch(:id)), Poller, *[@brand_name, fetcher])
      end
    end

    private
    def pages
      @config.fetch(:pages)
    end
    
    def actor_name(endpoint_type, endpoint_id)
      "#{@brand_name}_facebook_#{endpoint_type}_#{endpoint_id}".to_sym
    end

  end
end
