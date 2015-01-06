module Supervisors::Services::Twitter
  class Hashtag < Supervisors::Service
    include Supervisors::Services::Twitter::Common

    def boot
      @endpoints = SupervisionGroup.new

      hashtags_fetcher = Fetchers::Twitter::Hashtags.new(
        client, { hashtags: hashtags.join(' ') })

      @endpoints.supervise_as(
        @path.next_level(EndpointInfo.new('hashtags', hashtags.join(','))).actor_name,
        Poller, *[
          @path,
          hashtags_fetcher,
          {interval: 120}
        ])
    end

    private

    def hashtags
      [service_config.fetch(:hashtag)]
    end

  end
end
