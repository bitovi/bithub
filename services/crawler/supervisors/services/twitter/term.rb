module Supervisors::Services::Twitter
  class Term < Supervisors::Service
    include Supervisors::Services::Twitter::Common

    def boot
      super
      @endpoints = SupervisionGroup.new

      hashtags_fetcher = Fetchers::Twitter::Search.new(
        client, { term: term })

      @endpoints.supervise_as(
        @path.next_level(EndpointInfo.new('term', term)).actor_name,
        Poller, *[
          @path,
          hashtags_fetcher,
          {interval: 120}
        ])
    end

    private

    def term
      service_config.fetch(:term)
    end

  end
end
