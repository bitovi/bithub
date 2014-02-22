module Wrappers
  module Meetup

    class Rsvp
      include CoreHelpers
      attr_reader :member, :parent_event

      def initialize(rsvp)
        @r = symbolize_keys(rsvp)
        @parent_event = Wrappers::Meetup::Event.new(rsvp.andand[:event])
        @member = Wrappers::Meetup::Member.new(rsvp.andand[:member], rsvp.andand[:member_photo])
      end

      def id
        @r.andand[:rsvp_id]
      end

      def comment
        @cs.andand[:comment]
      end
      
      def response
        @r.andand[:response]
      end

      def created
        @created_at ||= Time.at(@r.andand[:created] / 1000)
      end
    end

  end
end
