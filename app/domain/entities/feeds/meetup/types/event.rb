module Entities
  module Meetup

    class Event < Protocol

      def find
        @payload.event_id && find_by_event_id.first
      end
      
      def build
        Entity.new({
          title: @payload.name,
          body: @payload.description,
          url: @payload.url,
          origin_ts: @payload.origin_timestamp,
          origin_id: @payload.event_id,
          props: {
            event_id: @payload.event_id,
          }
        })
      end

      def find_by_event_id
        Entity
        .feed('meetup')
        .type('event')
        .where(origin_id: @payload.event_id)
      end
    end

  end
end
