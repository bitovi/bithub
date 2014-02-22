module Events
  module Meetup

    class Event < Protocol
      extend Forwardable

      def_delegators :@venue, :composite_location, :lat, :lon
      def_delegators :@event, :id, :url, :status, :description, :created, :time, :hosts

      def digest_seed
        id + url + name + description + status + composite_location + lat + lon + host_ids_csv
      end

      def origin_id
        url
      end

      def host_ids_csv
        @event.hosts.map(&:id).map(&:to_s).compact.join(',')
      end

      def scheduled_at
        time.utc.iso8601
      end

      def origin_timestamp
        created.utc
      end 

      def wrap_reponse_parts
        @event = Wrappers::Meetup::Event.new(source_data)
        @venue = @event.venue
      end
    end
  end
end
