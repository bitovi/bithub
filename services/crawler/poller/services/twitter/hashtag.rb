module Supervisors::Services::Twitter
  class Hashtag < Supervisors::Service
    include Supervisors::Services::Twitter::Common

    def initialize
      super

      @endpoints.supervise_as(
        @path.next_level(EndpointInfo.new('hashtag', hashtag)).actor_name,
        Poller, *[
          @path,
          Fetchers::Twitter::Search.new(client, { term: hashtag }),
          {interval: 120}
        ])
    end

    private

    def hashtag
      '#' + service_config.fetch(:hashtag)
    end

  end
end
