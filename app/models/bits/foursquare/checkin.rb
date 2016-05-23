require 'bits/protocol'

module Bits
  module Foursquare

    class Checkin < Protocol

      def find
        Bit
          .feed('foursquare')
          .type('checkin')
          .where(origin_id: @event.id.to_s)
          .first
      end

      def data
        {
          title: title,
          origin_id: @event.id,
          origin_ts: @event.created_at,
          searchable_author: @event.user.firstName,
          props: {
            origin_author_id: @event.user.id,
            origin_author_name: @event.user.firstName,
            venue_id: @event.venue.id,
            venue_name: @event.venue.name
          }
        }
      end

      private

      def title
        "#{@event.user.firstName} #{@event.user.lastName} checkined at #{@event.venue.name}"
      end

    end
  end
end
