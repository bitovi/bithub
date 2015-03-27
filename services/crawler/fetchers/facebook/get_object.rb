require_relative 'base'

module Fetchers
  module Facebook
    class GetObject < Base

      def fetch(object_id, opts={})
        ::NewRelic::Agent.increment_metric('Custom/Fetches/Facebook/objects')
        args = {
          fields: FIELDS
        }.merge opts

        handle_errors do
          result = @client.get_object object_id, args
          [result]
        end
      end

    end
  end
end
