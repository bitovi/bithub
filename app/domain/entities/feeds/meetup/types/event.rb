module Entities
  module Meetup

    class Event < Protocol
      
      def find
        @event.event_id && 
          (find_by_event_url.first || find_by_event_id.first)
      end
      
      def build
        Entity.new({
          title: @event.name,
          body: @event.description,
          url: @event.url,
          origin_ts: @event.created_at,
          origin_id: @event.event_url,
          props: {
            location: @event.venue.composite_location,
            status: @event.status
            venue: @event.venue,
            scheduled_at: @event.scheduled_at,
            latitude: @event.venue.latitude,
            longitude: @event.venue.longitude,
            event_hosts: ActiveSupport::JSON.encode(@event.event_hosts),
            event_host_ids: @event.event_host_ids_csv,
          }
        })
      end

      def update
        @instance.title = @event.name
        @instance.body = @event.description
        @instance.props[:status] = @event.status
        @instance.props[:location] = @event.composite_location
        @instance.props[:scheduled_at] = @event.scheduled_at
        @instance.props[:latitude] = @event.latitude
        @instance.props[:longitude] = @event.longitude
        @instance.props[:event_host_ids] = @event.event_host_ids_csv
        @instance.props[:event_hosts] = ActiveSupport::JSON.encode(@event.event_hosts)
      end

      def determine_hosts
        @instance.event_hosts = @event.event_hosts.map do |host|
          Identity.find_by_provider_and_uid('meetup', host.andand[:member_id]).andand.user
        end.compact
      end

      def set_thread_ts
        @instance.thread_updated_ts = Time.parse(@instance.props[:scheduled_at])
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
        self.class.find_by_origin_id(@event.event_url)
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
