module Entities
  module Meetup
    class Rsvp < Protocol

      ResponseMapping = {
        'yes' => 'confirmed',
        'no' => 'rejected',
        'waitlist' => 'waitlist',
      }

      def find
        @event.rsvp_id && find_by_rsvp_id.first
      end
      
      def build
        Entity.new({
          title: "#{@event.member.name} RSVPd: #{@event.response}",
          body: @event.comment,
          origin_ts: @event.created_at,
          origin_id: @event.rsvp_id,
          props: {
            origin_author_id: @event.member.id,
            origin_author_name: @event.member.name,
            origin_author_avatar_url: @event.member.thumb_link,
            event_id: @event.event.id,
            response: @event.response,
          }
        })
      end
      
      def find_parent
        if @event.event.url
          Entities::Meetup::Event.find_by_origin_id(@event.event.url).first
        end
      end

      def taggify_state
        [ResponseMapping[@event.response]]
      end

      def find_by_rsvp_id
        Entities::Meetup::Rsvp.find_by_rsvp_id(@event.rsvp_id)
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

      def persist
        super unless @instance.parent_id.nil?
      end

      def persist!
        super unless @instance.parent_id.nil?
      end

    end

  end
end
