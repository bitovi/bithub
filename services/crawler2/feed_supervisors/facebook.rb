require 'koala'

module FeedSupervisors
  class Facebook
    include Celluloid

    def initialize(brand_name, cfg)
      @brand_name = brand_name
      @client = ::Koala::Facebook::API.new(cfg.fetch(:token))
    end

    def boot
      @endpoints = SupervisionGroup.new
      @endpoints.supervise_as(actor_name('pages'), Poller, *[Fetchers::Facebook::PageFeed, @client, pages])
    end

    private
    def pages
      @config.fetch(:pages)
    end
    
    def actor_name(endpoint_type)
      "#{@brand_name}_facebook_#{endpoint_type}".to_sym
    end

  end
end
