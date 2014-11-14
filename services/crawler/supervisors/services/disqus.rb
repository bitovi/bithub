require 'supervisors/service'

module Supervisors
  module Services
    class Disqus < Supervisors::Service
      def boot
        Celluloid.logger.info "Booting #{current_level}"
        fetcher = Fetchers::Disqus::Comments.new(api_key: api_key, forums: forums)
        @endpoints = SupervisionGroup.new
        @endpoints.supervise_as(
          child_name('forums'),
          Poller, *[
            @brand_name,
            @embed_name,
            fetcher,
            {interval: 60}
          ]
        )
      end

      private

      def forums
        config.fetch(:forums)
      end

      def token
        config.fetch(:access_token)
      end

      def api_key
        static_config.fetch(:disqus).fetch(:api_key)
      end
    end
  end
end
