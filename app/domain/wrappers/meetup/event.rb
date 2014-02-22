module Wrappers
  module Meetup

    class Event
      extend DataAccessible
      include CoreHelpers

      attr_reader :hosts
      data_accessors :id, :event_url, :name, :description, :status
      alias_method :url, :event_url

      def initialize(event)
        @data = symbolize_keys(event)
        @venue = Wrappers::Meetup::Venue.new(event.andand[:venue])
        @hosts = event.andand[:event_hosts].andand.map{|eh| Wrappers::Meetup::Member.new(eh)}
      end

      def created
        @created_at ||= Time.at(@data.andand[:created] / 1000)
      end

      def time
        @scheduled_at ||= Time.at(@data.andand[:time] / 1000)
      end

    end

  end
end
