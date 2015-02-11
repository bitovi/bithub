require_relative 'base'

module Fetchers
  module Facebook
    class GetFeed < Base

      COUNT = 250

      def fetch(object_id, opts={})
        count = opts[:count] || COUNT

        handle_errors do
          @client.get_connections object_id, 'feed', limit: count
        end
      end

    end
  end
end
