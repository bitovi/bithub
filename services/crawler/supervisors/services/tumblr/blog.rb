module Supervisors::Services::Tumblr
  class Blog < Supervisors::Service
    def boot
      @endpoints = SupervisionGroup.new

      blog_fetcher = Fetchers::Tumblr::Posts.new(hostname) 
      @endpoints.supervise_as(
        @path.next_level(EndpointInfo.new('blog_' + hostname)).actor_name,
        Poller, *[
          @path,
          blog_fetcher,
          { interval: 600 }
        ])
    end

    private

    def hostname
      service_config.fetch(:hostname) { [] }
    end
  end
end
