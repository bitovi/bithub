module Supervisors::Services::Twitter
  class Hashtag < Supervisors::Service
    include Supervisors::Services::Twitter::Common

    def boot
      @endpoints.supervise_as(
        @path.next_level(NodeTypes::EndpointInfo.new('hashtag', hashtag)).actor_name,
        Poller, *[
          @path,
          Fetchers::Twitter::Search.new(client, { term: hashtag }),
          { interval: Intervals::Services::TWITTER_HASHTAG }
        ])
    end

    private

    def hashtag
      '#' + service_config.fetch(:hashtag)
    end
  end
end
