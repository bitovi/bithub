module Fetchers
  module Meetup

    class Events
      include Protocol

      def initialize(client, opts)
        @client = client
        @group_ids = opts.fetch(:group_ids)
        @event_set = opts.fetch(:event_set)
      end

      def fetch
        events = @client.fetch :events, group_id: group_ids, status: "upcoming,past", fields: "event_hosts"
        @event_set.add_many(ids(events))
        events
      end

      # todo events that can be looked up in redis <3

      private
      def ids(events)
        events.map{|el| el.id}
      end

      def group_ids
        @group_ids.join ','
      end
    end
  end
end
