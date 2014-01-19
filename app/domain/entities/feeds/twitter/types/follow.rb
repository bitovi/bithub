module Entities
  module Twitter

    class Follow
      include Entities::Constructable
      include Entities::Determinable

      attr_reader :instance

      Relationships = {
        upstream: [],
        downstream: [],
        references: [],
      }

      def procure
        build
      end

      # Builder
      def build
        @instance = @persistor.new({
          title: "followed @#{@payload.target_screen_name}",
          origin_ts: @payload.origin_ts,
          thread_updated_ts: @payload.origin_ts,
          props: {
            feed: @payload.feed,
            type: @payload.type,
            origin_author_id: @payload.source_id,
            origin_author_name: @payload.source_screen_name,
          }
        })
        self
      end

      # Finders
      def find_by_author_id_and_target
      end

    end

  end
end
