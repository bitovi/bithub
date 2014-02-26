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
      end

      def created
        @created_at ||= Time.at(@data.andand[:created] / 1000)
      end
    end

  end
end
