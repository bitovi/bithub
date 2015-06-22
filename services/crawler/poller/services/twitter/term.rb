module Supervisors::Services::Twitter
  class Term < Supervisors::Service
    include Supervisors::Services::Twitter::Common

    def boot
      @endpoints.supervise_as(
        @path.next_level(NodeTypes::EndpointInfo.new('term', term)).actor_name,
        Poller, *[
          @path,
          Fetchers::Twitter::Search.new(client, { term: term }),
          { interval: Intervals::Services::TWITTER_TERM }
        ])
    end

    private

    def term
      service_config.fetch(:term)
    end
  end
end
