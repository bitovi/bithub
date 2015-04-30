module Entities
  module Tumblr

    class Post < Protocol
      def find
        @event.id && find_by_tumblr_id.first
      end

      def find_by_tumblr_id
        Entity
          .feed('tumblr')
          .where(origin_id: @event.id)
      end
    end
  end
end
