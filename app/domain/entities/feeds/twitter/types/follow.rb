module Entities
  module Twitter

    class Follow < Protocol

      def find
        nil
      end

      def build
        Entity.new({
          title: "followed @#{@event.target.screen_name}",
          origin_ts: @event.created_at,
          props: {
            origin_author_id: @event.source.id.to_s,
            origin_author_name: @event.source.screen_name,
            target: @event.target.screen_name,
          }
        })
      end

    end
  end
end
