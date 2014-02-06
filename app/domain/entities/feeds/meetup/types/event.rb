module Entities
  module Meetup
    class Event < Protocol
      
      Relationships = {
        upstream: [],
        downstream: [Entities::Meetup::Rsvp],
        references: [],
      }

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
            origin_author_id: @payload.origin_author_id,
            origin_author_name: @payload.origin_author_name,
          }
        })
      end

      def find_children
        if @payload.event_id
          Entities::Meetup::Rsvp.find_by_event_id(@payload.event_id).all
        end
      end

      def find_by_event_id
        Entities::Meetup::Event.find_by_event_id(@payload.event_id)
      end

      # Finders
      def self.find_by_event_id(event_id)
        Entity
        .feed('meetup')
        .type('event')
        .where(origin_id: event_id.to_s)
      end
    end

  end
end
