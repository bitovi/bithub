module Entities
  module Facebook

    class Comment < Protocol

      def initialize(event, payload)
        @event = event
        @payload = payload
      end

      def find
        if @payload.class.name == "Wrappers::Facebook::Comment"
          @payload.id && find_by_comment_id.first
        end
      end
      
      def find_by_comment_id
        Entity
        .feed('facebook')
        .type('comment')
        .where(origin_id: @payload.id)
      end

      def build
        if @payload.class.name == "Wrappers::Facebook::Comment"
          build_from_comment
        end
      end

      def build_from_comment
        Entity.new({
          title: @payload.message,
          origin_id: @payload.id,
          origin_ts: @payload.created_time,
          props: {
            origin_author_id: @payload.poster_id,
            origin_author_name: @payload.poster_name,
          }
        })
      end

    end
  end
end
