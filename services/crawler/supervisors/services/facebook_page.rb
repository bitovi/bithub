require 'koala'

module Supervisors::Services::Facebook
  class Page < Supervisors::Service
    def boot
      @endpoints = SupervisionGroup.new

      fetcher = Fetchers::Facebook::PageFeed.new(
        ::Koala::Facebook::API.new(page_token))

      @endpoints.supervise_as(
        @path.child_actor_name(page_id),
        Poller, *[
          @path,
          fetcher,
          {interval: 60}
        ])
    end

    private

    def page_id
      service_config.fetch(:id)
    end
  end
end
