module Supervisors::Services::Twitter
  class Hashtag < Supervisors::Service
    include Supervisors::Services::Twitter::Common

    def initialize(path, service_info)
      super

      @endpoints.supervise_as(
        @path.next_level(NodeTypes::EndpointInfo.new('search', hashtags.join(','))).actor_name,
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
