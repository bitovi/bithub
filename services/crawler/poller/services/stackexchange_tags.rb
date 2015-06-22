require 'services/intervals'

module Supervisors::Services::Stackexchange
  class Tags < Supervisors::Service

    def boot
      @endpoints.supervise_as(
        @path.next_level(NodeTypes::EndpointInfo.new('questions', tags_csv)).actor_name,
        Poller, *[
          @path,
          Fetchers::Stackexchange::Questions.new(tags: tags, token: token),
          { interval: Intervals::Services::STACKEXCHANGE_QUESTIONS }
        ])

      @endpoints.supervise_as(
        @path.next_level(NodeTypes::EndpointInfo.new('search', tags_csv)).actor_name,
        Poller, *[
          @path,
          Fetchers::Stackexchange::Search.new(tags: tags, token: token),
          { interval: Intervals::Services::STACKEXCHANGE_SEARCH }
        ])
    end

    private

    def tags
      service_config.fetch(:tags)
    end

    def tags_csv
      tags.join(',')
    end
  end
end
