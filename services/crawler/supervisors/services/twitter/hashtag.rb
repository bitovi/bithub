module Supervisors::Services::Twitter
  class Hashtag < Supervisors::Service
    include Supervisors::Services::Twitter::Common

    def boot
      @endpoints = SupervisionGroup.new

      hashtags_fetcher = Fetchers::Twitter::Hashtags.new(
        client, { hashtags: hashtags })

      @endpoints.supervise_as(
        @path.child_actor_name("hashtags_#{hashtags.join('_')}"),
        Poller, *[
          @path,
          hashtags_fetcher,
          {interval: 120}
        ])
    end

    private

    def hashtags
      service_config.fetch(:hashtags)
    end

  end
end
