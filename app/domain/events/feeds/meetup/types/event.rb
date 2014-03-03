module Events
  module Meetup

    class Event < Protocol
      extend Forwardable

      def_delegators :@event, :id, :name, :url, :status,
        :description, :created_at, :hosts,
        :host_ids, :host_ids_csv,
        :host_names, :host_names_csv

      attr_reader :venue

      def digest_seed
        id + url + name +
        description + status +
        @venue.composite_location +
        host_ids_csv +
        self.class.name
      end

      def scheduled_at
        @event.scheduled_at.utc.iso8601
      end

      def wrap_response
        @event = Wrappers::Meetup::Event.new(source_data)
        @venue = Wrappers::Meetup::Venue.new(source_data[:venue])
        self
      end
    end
  end
end
