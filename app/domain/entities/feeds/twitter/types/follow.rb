module Entities
  module Twitter

    class Follow < Protocol

      Relationships = {
        upstream: [],
        downstream: [],
        references: [],
      }

      def procure
        @instance ||= build
        self
      end

      # Builder
      def build
        Entity.new({
          title: "followed @#{@payload.target_screen_name}",
          origin_ts: @payload.origin_ts,
          thread_updated_ts: @payload.origin_ts,
          props: {
            origin_author_id: @payload.source_id,
            origin_author_name: @payload.source_screen_name,
            target_screen_name: @payload.target_screen_name,
          }
        })
      end

      # Finders
      def find_by_author_id_and_target
      end

    end

  end
end
