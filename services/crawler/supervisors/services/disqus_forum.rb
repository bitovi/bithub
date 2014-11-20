require 'supervisors/service'

module Supervisors
  module Services
    class DisqusForum < Supervisors::Service
      def boot
        fetcher = Fetchers::Disqus::Comments.new(
          api_key: api_key, forum: forum_url)

        @endpoints.supervise_as(
          @path.child_actor_name(forum_url),
          Poller, *[
            @path,
            fetcher,
            {interval: 60}
          ]
        )
      end

      private

      def forum_url
        config.fetch(:url)
      end

      def api_key
        static_config.fetch(:disqus).fetch(:api_key)
      end
    end
  end
end
