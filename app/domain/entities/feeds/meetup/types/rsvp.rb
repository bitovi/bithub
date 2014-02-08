module Entities
  module Meetup
    class Rsvp < Protocol
      
      Relationships = {
        upstream: [Entities::Meetup::Event],
        downstream: [],
        references: [],
      }

      def find
        @payload.rsvp_id && find_by_rsvp_id.first
      end
      
      def build
        Entity.new({
          title: "#{@payload.origin_author_name} RSVPd: #{@payload.response}",
          body: @payload.comment,
          origin_ts: @payload.origin_timestamp,
          origin_id: @payload.rsvp_id,
          props: {
            origin_author_id: @payload.origin_author_id,
            origin_author_name: @payload.origin_author_name,
            event_id: @payload.parent_event_id,
            response: @payload.response,
            origin_author_avatar_url: @payload.origin_author_avatar_url,
          }
        })
      end
      
      def find_parent
        if @payload.parent_event_id
          Entities::Meetup::Event.find_by_event_id(@payload.parent_event_id).first
        end
      end

      def find_by_rsvp_id
        Entities::Meetup::Rsvp.find_by_rsvp_id(@payload.rsvp_id)
      end

      # Finders
      def self.find_by_rsvp_id(rsvp_id)
        Entity
        .feed('meetup')
        .type('rsvp')
        .where(origin_id: rsvp_id.to_s)
      end

      def self.find_by_event_id(event_id)
        Entity
        .feed('meetup')
        .type('rsvp')
        .where("props -> 'event_id' = '#{event_id.to_s}'")
      end
    end

  end
end
