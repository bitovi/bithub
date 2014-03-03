module Events
  module Meetup

    class Rsvp < Protocol
      extend Forwardable

      def_delegators :@rsvp, :id, :rsvp_id,
        :comment, :response, :created_at

      def digest_seed
        @rsvp.id.to_s + self.class.name
      end

      def wrap_response
        @rsvp = Wrappers::Meetup::Rsvp.new(source_data)
        @event = Wrappers::Meetup::Event.new(source_data[:event])
        @member = Wrappers::Meetup::Member.new(source_data[:member], source_data[:member_photo])
      end

    end
  end
end
