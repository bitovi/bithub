module Supervisors::Services::Tumblr
  class Tag < Supervisors::Service

    def initialize
      super

      @endpoints.supervise_as(
        @path.next_level(EndpointInfo.new('tagged', tag)).actor_name,
        Poller, *[
          @path,
          Fetchers::Tumblr::Tagged.new(tag),
          { interval: 600 }
        ])
    end

    private

    def tag
      service_config.fetch(:tag)
    end
  end
end
