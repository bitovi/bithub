module Supervisors::Services::Twitter
  class Term < Supervisors::Service
    include Supervisors::Services::Twitter::Common

    def initialize
      super

      @endpoints.supervise_as(
        @path.next_level(EndpointInfo.new('term', term)).actor_name,
        Poller, *[
          @path,
          Fetchers::Twitter::Search.new(client, { term: term }),
          {interval: 120}
        ])
    end

    private

    def term
      service_config.fetch(:term)
    end

  end
end
