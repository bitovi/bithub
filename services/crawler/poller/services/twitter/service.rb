module Supervisors::Services::Twitter
  class Hashtag < Supervisors::Service
    include Supervisors::Services::Twitter::Common

    def initialize
      super

      @endpoints.supervise_as(
        @path.next_level(EndpointInfo.new('search', hashtags.join(','))).actor_name,
        Poller, *[
          @path,
          Fetchers::Twitter::Hashtags.new(client, { term: term }),
          {interval: 120}
        ])
    end

    private

    def term
      [service_config.fetch(:term)]
    end

  end
end
