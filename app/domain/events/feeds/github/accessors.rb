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

      def actor
        @actor ||= Wrappers::Actor.new(source_data.andand[:actor])
      end

      def repo
        @repo ||= Wrappers::Repo.new(source_data.andand[:repo])
      end

      def origin_ts
        ts_str = source_data.andand[:created_at]
        Time.parse(ts_str).utc
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
