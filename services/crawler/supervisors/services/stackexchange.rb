module Supervisors::Services
  class Stackexchange < Supervisors::Service
    def boot
      @endpoints = SupervisionGroup.new

      questions_fetcher = Fetchers::Stackexchange::Questions.new(
        terms: terms,
        token: token
      )

      @endpoints.supervise_as(
        actor_name,
        Poller, *[
          @brand_name,
          @embed_name,
          questions_fetcher,
          {interval: 30}
        ]
      )
      
      search_fetcher = Fetchers::Stackexchange::Search.new(
        terms: terms,
        token: token
      )

      @endpoints.supervise_as(
        actor_name,
        Poller, *[
          @brand_name,
          @embed_name,
          search_fetcher,
          {interval: 60}
        ])
    end

    private

    def actor_name
      "#{@brand_name}_stackexchange".to_sym
    end

    def terms
      service_config.fetch(:terms)
    end

    def token
      service_config.fetch(:token)
    end

  end
end
