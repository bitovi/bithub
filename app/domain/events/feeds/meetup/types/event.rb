module Events
  module Meetup

    class Event < Protocol
      extend Forwardable

      def_delegators :@venue, :composite_location, :lat, :lon

      def_delegators :@event, :id, :name, :url, :status,
        :description, :created, :time, :hosts,
        :host_ids, :host_ids_csv,
        :host_names, :host_names_csv

      def digest_seed
        id + url + name +
        description + status +
        composite_location +
        host_ids_csv +
        self.class.name
      end

      def origin_id
        url
      end

      def scheduled_at
        time.utc.iso8601
      end

      def origin_timestamp
        created.utc
      end 

      def wrap_reponse
        @event = Wrappers::Meetup::Event.new(source_data)
        @venue = Wrappers::Meetup::Venue.new(source_data[:venue])
        @hosts = source_data.fetch(:event_hosts).map{|eh| Wrappers::Meetup::Member.new(eh)}
      end
    end
  end
end
