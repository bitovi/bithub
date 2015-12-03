require 'events/protocol'

module Events
  module Meetup

    class EventEvent < Protocol
      extend Forwardable

      def_delegators :@event, :id, :name, :url, :status,
        :description, :created_at, :hosts,
        :host_ids, :host_ids_csv,
        :host_names, :host_names_csv

      attr_reader :venue, :group

      def digest_seed
        id\
          + url\
          + name\
          + description\
          + status\
          + host_ids_csv.to_s\
          + self.class.name
      end

      def scheduled_at
        @event.scheduled_at.utc.iso8601
      end

      def wrap_response
        @event = Wrappers::Meetup::Event.new(source_data)
        @venue = Wrappers::Meetup::Venue.new(source_data[:venue]) if source_data[:venue]
        @group = Wrappers::Meetup::Group.new(source_data[:group]) if source_data[:group]
        self
      end
    end
  end
end
