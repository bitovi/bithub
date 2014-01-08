module Entities
  module Twitter

    class Follow
      include Entities::Constructable

      Relationships = {
        upstream: [],
        downstream: [],
        references: [],
      }

      # Builder
      def build
        Hash.new({
          title: "followed @#{@payload.target_screen_name}",
          props: {
            origin_author_id: @payload.source_id,
            origin_author_name: @payload.source_screen_name,
          }
        })
      end

      # Finders
      def find_by_author_id_and_target
      end

    end

  end
end
