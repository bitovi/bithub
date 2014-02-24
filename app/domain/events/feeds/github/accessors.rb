module Events
  module Github

    module Accessors

      def event_id
        source_data.andand[:id]
      end

      def payload
        source_data.andand[:payload]
      end

      def action
        payload.andand[:action]
      end

      def origin_timestamp
        Time.parse(source_data.andand[:created_at]).utc
      end

      module Refs
        def ref_type
          payload.andand[:ref_type]
        end

        def ref
          payload.andand[:ref].to_s
        end
      end

    end

  end
end
