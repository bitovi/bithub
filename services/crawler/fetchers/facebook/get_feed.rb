require_relative 'base'

module Fetchers
  module Facebook
    class GetFeed < Base

      def fetch(object_id, opts={})
        args = {
          fields: FIELDS,
          limit: LIMIT
        }.merge opts

        handle_errors do
          @client.get_connections object_id, 'feed', args, api_version: 'v2.2'
        end
      end

    end
  end
end
