module Wrappers
  module Meetup

    class Rsvp
      extend DataAccessible
      include CoreHelpers

      has :rsvp_id, :response
      maybe_has :comment

      attr_reader :member, :event
      alias_method :id, :rsvp_id

      def initialize(rsvp)
        @data = symbolize_keys(rsvp)
        @event = Wrappers::Meetup::Event.new(rsvp.andand[:event])
        @member = Wrappers::Meetup::Member.new(rsvp.andand[:member], rsvp.andand[:member_photo])
      end

      def created
        @created_at ||= Time.at(@data.andand[:created] / 1000)
      end
    end

  end
end
