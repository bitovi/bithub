module Supervisors
  module Services
    class StackexchangeTags < Supervisors::Service
      def boot
        @endpoints = SupervisionGroup.new

        questions_fetcher = Fetchers::Stackexchange::Questions.new(
          tags: tags,
          token: token
        )

        @endpoints.supervise_as(
          @path.child_actor_name('questions'),
          Poller, *[
            @path,
            questions_fetcher,
            {interval: 30}
          ]
        )

        search_fetcher = Fetchers::Stackexchange::Search.new(
          tags: tags,
          token: token
        )

        @endpoints.supervise_as(
          @path.child_actor_name('search'),
          Poller, *[
            @path,
            search_fetcher,
            {interval: 60}
          ])
      end

      private

      def tags
        service_config.fetch(:tags)
      end
    end
  end
end
