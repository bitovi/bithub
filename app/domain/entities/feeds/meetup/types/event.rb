module Entities
  module Meetup

    class Event < Protocol
      
      Relationships = {
        upstream: [],
        downstream: [Entities::Meetup::Rsvp],
        references: [],
      }

      def find
        @payload.event_id && find_by_event_id.first
      end
      
      def build
        Entity.new({
          title: @payload.name,
          body: @payload.description,
          url: @payload.url,
          origin_ts: @payload.origin_timestamp,
          origin_id: @payload.event_id,
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

      def determine_hosts
        @payload.event_hosts.each do |host|
          if (ident = Identity.find_by_provider_and_uid('meetup', host.andand[:member_id]))
            @instance.hosts << ident.user if ident.user
          end
        end
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
        Entities::Meetup::Event.find_by_event_id(@payload.event_id)
      end

      # Finders
      def self.find_by_event_id(event_id)
        Entity
        .feed('meetup')
        .type('event')
        .where(origin_id: event_id.to_s)
      end
    end

  end
end
