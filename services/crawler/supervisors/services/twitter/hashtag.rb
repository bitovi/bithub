module Supervisors::Services::Twitter
  class Hashtag < Supervisors::Service
    include Supervisors::Services::Twitter::Common

    def boot
      super
      @endpoints = SupervisionGroup.new

      hashtags_fetcher = Fetchers::Twitter::Search.new(
        client, { term: hashtag })

      @endpoints.supervise_as(
        @path.next_level(EndpointInfo.new('hashtag', hashtag)).actor_name,
        Poller, *[
          @path,
          hashtags_fetcher,
          {interval: 120}
        ])
    end

    private

    def hashtag
      hashtag = service_config.fetch(:hashtag)
      (hashtag.first != '#') ? '#' + hashtag : hashtag
    end

  end
end
