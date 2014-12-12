module Supervisors::Services::Tumblr
  class Tagged < Supervisors::Service
    def boot
      @endpoints = SupervisionGroup.new

      tag_fetcher = Fetchers::Tumblr::Tagged.new(tag)
      @endpoints.supervise_as(
        @path.next_level(EndpointInfo.new('tagged_' + tag)).actor_name,
        Poller, *[
          @path,
          tag_fetcher,
          { interval: 600 }
        ])
    end

    private

    def tag
      service_config.fetch(:tag)
    end
  end
end
