module Entities
  module Twitter

    class Follow < Protocol

      def find
        nil
      end

      def build
        Entity.new({
          title: "followed @#{@payload.target.screen_name}",
          origin_ts: @payload.created_at,
          props: {
            origin_author_id: @payload.source.id.to_s,
            origin_author_name: @payload.source.screen_name,
            target: @payload.target.screen_name,
          }
        })
      end

    end
  end
end
