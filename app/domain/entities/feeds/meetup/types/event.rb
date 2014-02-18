module Entities
  module Meetup

    class Event < Protocol
      
      Relationships = {
        upstream: [],
        downstream: [Entities::Meetup::Rsvp],
        references: [],
      }

      def find
        @payload.event_id && 
          (find_by_event_url.first || find_by_event_id.first)
      end
      
      def build
        Entity.new({
          title: @payload.name,
          body: @payload.description,
          url: @payload.url,
          origin_ts: @payload.origin_timestamp,
          origin_id: @payload.event_url,
          props: {
            location: @payload.composite_location,
            venue: @payload.venue,
            scheduled_at: @payload.scheduled_at,
            latitude: @payload.latitude,
            longitude: @payload.longitude,
            event_hosts: ActiveSupport::JSON.encode(@payload.event_hosts),
            event_host_ids: @payload.event_host_ids_csv,
          }
        })
      end

      def update
        @instance.title = @payload.name
        @instance.body = @payload.description
        @instance.props[:status] = @payload.status
        @instance.props[:location] = @payload.composite_location
        @instance.props[:scheduled_at] = @payload.scheduled_at
        @instance.props[:latitude] = @payload.latitude
        @instance.props[:longitude] = @payload.longitude
        @instance.props[:event_host_ids_csv] = @payload.event_host_ids_csv
        @instance.props[:event_hosts] = ActiveSupport::JSON.encode(@payload.event_hosts)
      end

      def determine_hosts
        @instance.event_hosts = @payload.event_hosts.map do |host|
          Identity.find_by_provider_and_uid('meetup', host.andand[:member_id]).andand.user
        end.compact
      end

      def set_thread_ts
        @instance.thread_updated_ts = @instance.props[:scheduled_at]
      end

      def find_children
        if @payload.event_id
          Entities::Meetup::Rsvp.find_by_event_id(@payload.event_id).all
        end
      end
      
      def find_by_event_id
        self.class.find_by_origin_id(@payload.event_id)
      end

      def find_by_event_url
        self.class.find_by_origin_id(@payload.event_url)
      end

      # Finders
      def self.find_by_origin_id(origin_id)
        Entity
        .feed('meetup')
        .type('event')
        .where(origin_id: origin_id)
      end
    end

  end
end
