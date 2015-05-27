require_relative 'base'

module Fetchers
  module Facebook
    class GetObject < Base

      def fetch(opts={})
        args = {
          fields: FIELDS
        }.merge opts

        handle_errors do
          result = @client.get_object @object_id, args, api_version: 'v2.2'
          [result]
        end
      end

    end
  end
end
