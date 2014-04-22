module FeedSupervisors
  class Questions
    include Celluloid

    def initialize(brand_name)
      @brand_name = brand_name
      boot
    end

    def boot
      Celluloid.logger.info "Skipping StackExchange supervisor for #{@brand_name}"
      @endpoints = SupervisionGroup.new

      # fetchers = Fetchers::StackExchange::Questions.new(terms: terms)
      # @endpoints.supervise_as(
      #   actor_name,
      #   Poller,
      #   *[@brand_name, fetchers, {interval: 30}])
    end

    private

    def actor_name
      "#{@brand_name}_stackexchange".to_sym
    end

    def terms
      Celluloid::Actor[:configurator].feed_config(@brand_name, :stackoverflow).fetch(:terms)
    end

  end
end

