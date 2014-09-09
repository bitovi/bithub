module Events
  module Github

    module Accessors

      def event_id
        source_data.fetch(:id)
      end

      def payload
        source_data.fetch(:payload)
      end

      def origin_timestamp
        Time.parse(source_data.fetch(:created_at)).utc
      end
      
      def created_at
        origin_timestamp
      end

      module Refs
        def ref_type
          payload.fetch(:ref_type)
        end

        def ref
          payload.fetch(:ref).to_s
        end
      end

    end

  end
end
