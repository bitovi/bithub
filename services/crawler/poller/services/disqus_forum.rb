require 'supervisors/service'

module Supervisors::Services::Disqus
  class Forum < Supervisors::Service

    def initialize
      super

      @endpoints.supervise_as(
        @path.next_level(EndpointInfo.new('comments', forum_url)).actor_name,
        Poller, *[
          @path,
          Fetchers::Disqus::Comments.new(api_key: api_key, forum: forum_url),
          {interval: 60}
        ])
    end

    private

    def forum_url
      service_config.fetch(:url)
    end

    def api_key
      static_config.fetch(:disqus).fetch(:api_key)
    end
  end
end
