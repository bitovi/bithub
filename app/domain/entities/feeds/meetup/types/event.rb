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
          props: {
            event_id: @payload.event_id,
            event_id: @payload.event_id,
          }
        })
      end

      def find_by_event_id
        Entity.tagged_with(['meetup', 'event'])
        .where("props -> 'event_id' = '#{@payload.event_id}'")
      end
    end

  end
end
