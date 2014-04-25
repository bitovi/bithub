module FeedSupervisors
  class Disqus
    include Celluloid

    def initialize(brand_name)
      @brand_name = brand_name
    end

    def boot
      Celluloid.logger.info "Booting Disqus supervisor for #{@brand_name}"
      @endpoints = SupervisionGroup.new

      @endpoints.supervise_as(
        actor_name('forums'),
        Poller,
        *[@brand_name, Fetchers::Disqus::Comments.new(api_key: api_key, forums: forums)]
      )
    end

    private
    def config
      Celluloid::Actor[:configurator].feed_config(@brand_name, :disqus)
    end
    
    def forums
      config.fetch(:forums)
    end

    def token
      config.fetch(:access_token)
    end
    
    def api_key
      Celluloid::Actor[:configurator].static_config.fetch(:disqus).fetch(:api_key)
    end
    
    def actor_name(endpoint_type)
      "#{@brand_name}_disqus_#{endpoint_type}".to_sym
    end

  end
end
