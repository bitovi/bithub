module Wrappers
  module Meetup

    class Rsvp
      include DataAccessible
      include CoreHelpers

      has :rsvp_id, :response
      maybe_has :comment

      def initialize(rsvp)
        @data = symbolize_keys(rsvp)
      end

      def created
        @created ||= Time.at(@data.andand[:created] / 1000).utc
      end

      alias_method :id, :rsvp_id
      alias_method :created_at, :created
    end

  end
end
