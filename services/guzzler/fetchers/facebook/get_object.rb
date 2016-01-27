require_relative 'base_fetcher'

module Guzzler::Fetchers

  module Facebook
    class GetObject < BaseFetcher

      def fetch(object_id)
        log_fetch

        handle_errors do
          result = client.get_object object_id, { fields: FIELDS }, api_version: 'v2.2'
          [result]
        end
      end
    end
  end
end
