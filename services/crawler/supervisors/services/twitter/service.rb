module Supervisors::Services::Twitter
  class Hashtag < Supervisors::Service
    include Supervisors::Services::Twitter::Common

    def boot
      @endpoints = SupervisionGroup.new

      hashtags_fetcher = Fetchers::Twitter::Hashtags.new(
        client, { term: term })

      @endpoints.supervise_as(
        @path.next_level(EndpointInfo.new('search', hashtags.join(','))).actor_name,
        Poller, *[
          @path,
          hashtags_fetcher,
          {interval: 120}
        ])
    end

    private

    def term
      [service_config.fetch(:term)]
    end

  end
end
