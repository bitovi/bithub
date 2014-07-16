module FeedSupervisors
  class Stackexchange
    include Celluloid

    def initialize(brand_name)
      @brand_name = brand_name
      boot
    end

    def boot
      Celluloid.logger.info "Booting StackExchange supervisor for #{@brand_name}"
      @endpoints = SupervisionGroup.new

      fetcher = Fetchers::Stackexchange::Questions.new(terms: terms, token: token)
      @endpoints.supervise_as(
        actor_name,
        Poller,
        *[@brand_name, fetcher, {interval: 30}])
      
      fetcher = Fetchers::Stackexchange::Search.new(terms: terms, token: token)
      @endpoints.supervise_as(
        actor_name,
        Poller,
        *[@brand_name, fetcher, {interval: 60}])
    end

    private

    def actor_name
      "#{@brand_name}_stackexchange".to_sym
    end

    def config
      Celluloid::Actor[:configurator].feed_config(@brand_name, :stackexchange)
    end

    def terms
      config.fetch(:terms)
    end

    def token
      config.fetch(:token)
    end

  end
end
