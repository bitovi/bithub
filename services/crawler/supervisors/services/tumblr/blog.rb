module Supervisors::Services::Tumblr
  class Blog < Supervisors::Service
    def boot
      @endpoints = SupervisionGroup.new

      blog_fetcher = Fetchers::Tumblr::Posts.new(hostname) 
      @endpoints.supervise_as(
        @path.child_actor_name("blog_#{hostname}"),
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
