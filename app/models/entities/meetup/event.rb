module Entities
  module Meetup

    class Event < Protocol

      def find
        @event.id &&
          (find_by_event_url.first || find_by_event_id.first)
      end

      def data
        tmp = {
          title: @event.name,
          body: @event.description,
          url: @event.url,
          origin_id: @event.url,
          origin_ts: @event.created_at,
          thread_updated_ts: Time.parse(@event.scheduled_at),
          props: {
            status: @event.status,
            scheduled_at: @event.scheduled_at,
            event_host_ids: @event.host_ids_csv
          }
        }

        tmp[:props][:location] = @event.venue.composite_location if @event.venue
        tmp[:props][:group_name] = @event.group.name if @event.group

        tmp
      end

      def update
        @instance.title = @event.name
        @instance.body = @event.description
        @instance.thread_updated_ts = Time.parse(@event.scheduled_at)

        @instance.props = {}
        @instance.props[:status] = @event.status
        @instance.props[:scheduled_at] = @event.scheduled_at
        @instance.props[:event_host_ids] = @event.host_ids_csv
        @instance.props[:location] = @event.venue.composite_location if @event.venue
        @instance.props[:group_name] = @event.group.name if @event.group
      end

      def find_children
        if @event.id
          Entities::Meetup::Rsvp.find_by_event_id(@event.id).all
        end
      end

      def find_by_event_id
        self.class.find_by_origin_id(@event.id)
      end

      def find_by_event_url
        self.class.find_by_origin_id(@event.url)
      end

      # Finders
      def self.find_by_origin_id(id)
        Entity
        .feed('meetup')
        .type('event')
        .where(origin_id: id)
      end
    end

  end
end
