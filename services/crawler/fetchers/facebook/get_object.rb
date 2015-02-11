require_relative 'base'

module Fetchers
  module Facebook
    class GetObject < Base

      def fetch(object_id, opts={})
        handle_errors do
          @client.get_object object_id
        end
      end

    end
  end
end
