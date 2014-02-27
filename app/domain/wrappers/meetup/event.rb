module Wrappers
  module Meetup

    class Event
      include DataAccessible
      include CoreHelpers

      has :id, :event_url, :name, :description, :status
      attr_reader :hosts, :venue

      def initialize(event)
        _event = symbolize_keys(event)
        @data = _event
        @hosts = _event.andand[:event_hosts].andand.map{|eh| Wrappers::Meetup::Member.new(eh)}
      end

      def created
        @created_at ||= Time.at(@data.andand[:created] / 1000).utc
      end

      def time
        @scheduled_at ||= Time.at(@data.andand[:time] / 1000).utc
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

      alias_method :url, :event_url
      alias_method :scheduled_at, :time
      alias_method :created_at, :created
    end

  end
end
