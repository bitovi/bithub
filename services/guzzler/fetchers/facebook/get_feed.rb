require_relative 'base_fetcher'

module Guzzler::Fetchers

  module Facebook
    class GetFeed < BaseFetcher

      def fetch
        log_fetch

        handle_errors do
          client.get_connections fb_object_id,'feed', { fields: FIELDS, limit: LIMIT }, api_version: 'v2.2'
        end
      end

      private

      def fb_object_id
        @service.config.fetch(:id)
      end
    end
  end
end
