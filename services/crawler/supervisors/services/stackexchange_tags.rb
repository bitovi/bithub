module Supervisors::Services::Stackexchange
  class Tags < Supervisors::Service

    def boot
      super
      @endpoints = SupervisionGroup.new

      questions_fetcher = Fetchers::Stackexchange::Questions.new(
        tags: tags, token: token)

      @endpoints.supervise_as(
        @path.next_level(EndpointInfo.new('questions', tags_csv)).actor_name,
        Poller, *[
          @path,
          questions_fetcher,
          {interval: 30}
        ])

      search_fetcher = Fetchers::Stackexchange::Search.new(
        tags: tags, token: token)

      @endpoints.supervise_as(
        @path.next_level(EndpointInfo.new('search', tags_csv)).actor_name,
        Poller, *[
          @path,
          search_fetcher,
          {interval: 60}
        ])
    end

    private

    def tags
      service_config.fetch(:tags)
    end

    def tags_csv
      tags.join(',')
    end
  end
end
