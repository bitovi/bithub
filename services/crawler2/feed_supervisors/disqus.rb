module FeedSupervisors
  class Disqus
    include Celluloid

    def initialize(brand_name, cfg)
      @brand_name = brand_name
      @client = Object.new #Clients::Disqus.new(cfg.fetch(:token))
    end

    def boot
      Celluloid.logger.info "Booting Disqus supervisor for #{@brand_name}"
      @endpoints = SupervisionGroup.new
      @endpoints.supervise_as(actor_name('forums'), Poller , *[{forums: forums}, @client, Fetchers::Disqus::ForumsFeed])
    end

    private
    def forums
      @config.fetch(:forums)
    end
    
    def actor_name(endpoint_type)
      "#{@brand_name}_disqus_#{endpoint_type}".to_sym
    end

  end
end
