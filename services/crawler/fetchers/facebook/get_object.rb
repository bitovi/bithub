require_relative 'base'

module Fetchers
  module Facebook
    class GetObject < Base

      def fetch(object_id, opts={})
        args = {
          fields: FIELDS
        }.merge opts

        handle_errors do
          @client.get_object object_id, args, api_version: 'v2.2'
        end
      end

    end
  end
end
