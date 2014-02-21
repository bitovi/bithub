module Wrappers
  module Meetup

    class Event
      include CoreHelpers

      def initialize(event)
        @e = symbolize_keys(event)
      end

      def id
        @e.andand[:id]
      end
      
      def url
        @e.andand[:event_url]
      end

      def name
        @e.andand[:name]
      end

      def description
        @e.andand[:description]
      end

      def status
        @e.andand[:status]
      end
      
      def hosts
        @e.andand[:event_hosts]
      end

      def created
        @created_at ||= Time.at(@e.andand[:created] / 1000)
      end

      def time
        @scheduled_at ||= Time.at(@e.andand[:time] / 1000)
      end

    end

  end
end
