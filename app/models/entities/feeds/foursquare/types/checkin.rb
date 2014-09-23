module Entities
  module Foursquare

    class Checkin < Protocol

      def find
        Entity
          .feed('foursquare')
          .type('checkin')
          .where(origin_id: @event.id.to_s)
          .first
      end

      def build
        Entity.new({
          title: title,
          #body: @event.message,
          #url: @event.link,
          origin_id: @event.id,
          origin_ts: @event.created_at,
          props: {
            origin_author_id: @event.user.id,
            origin_author_name: @event.user.firstName,
            venue_id: @event.venue.id,
            venue_name: @event.venue.name
          }
        })
      end

      private

      def title
        "#{@event.user.firstName} #{@event.user.lastName} checkined at #{@event.venue.name}"
      end

    end

  end
end
