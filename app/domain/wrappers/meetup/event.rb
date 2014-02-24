module Wrappers
  module Meetup

    class Event
      extend DataAccessible
      include CoreHelpers

      data_accessors :id, :event_url, :name, :description, :status

      attr_reader :hosts, :venue
      alias_method :url, :event_url

      def initialize(event)
        _event = symbolize_keys(event)
        @data = _event
        @venue = Wrappers::Meetup::Venue.new(_event.andand[:venue])
        @hosts = _event.andand[:event_hosts].andand.map{|eh| Wrappers::Meetup::Member.new(eh)}
      end

      def created
        @created_at ||= Time.at(@data.andand[:created] / 1000)
      end

      def time
        @scheduled_at ||= Time.at(@data.andand[:time] / 1000)
      end
      
      def host_ids
        @hosts.andand.map(&:id)
      end

      def host_names
        @hosts.andand.map(&:name)
      end

      def host_ids_csv
        host_ids.andand.join(',')
      end

      def host_names_csv
        host_names.andand.join(',')
      end

    end

  end
end
