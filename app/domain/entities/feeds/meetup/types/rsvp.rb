module Entities
  module Meetup

    class Rsvp < Protocol

      def find
        @payload.rsvp_id && find_by_rsvp_id.first
      end
      
      def build
        Entity.new({
          title: @payload.comment,
          origin_ts: @payload.origin_timestamp,
          origin_id: @payload.rsvp_id,
          props: {
            origin_author_id: @payload.origin_author_id,
            origin_author_name: @payload.origin_author_name,
            event_id: @payload.parent_event_id,

          }
        })
      end

      def find_by_rsvp_id
        Entity
        .feed('meetup')
        .type('rsvp')
        .where(origin_id: @payload.rsvp_id)
      end
    end

  end
end
