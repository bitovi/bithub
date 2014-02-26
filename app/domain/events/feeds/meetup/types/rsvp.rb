module Events
  module Meetup

    class Rsvp < Protocol
      extend Forwardable

      def_delegators :@rsvp,
        :id, :comment, :response

      def_delegator :@event, :id, :event_id

      def_delegator :@member, :id, :member_id
      def_delegator :@member, :name, :member_name
      def_delegator :@member, :thumb_link, :member_photo_thumb_link

      def digest_seed
        @rsvp.id.to_s + self.class.name
      end

      def origin_id
        @rsvp.id
      end

      def origin_timestamp
        @rsvp.created.utc
      end
      
      def wrap_reponse
        @rsvp = Wrappers::Meetup::Rsvp.new(source_data)
        @event = Wrappers::Meetup::Event.new(source_data[:event])
        @member = Wrappers::Meetup::Member.new(source_data[:member], source_data[:member_photo])
      end

      alias_method :origin_author_id, :member_id
      alias_method :origin_author_name, :member_name
      alias_method :origin_author_avatar_url, :member_photo_thumb_link
    end
  end
end
