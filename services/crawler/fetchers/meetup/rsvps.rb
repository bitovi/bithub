module Fetchers
  module Meetup

    class Rsvps
      include Protocol

      def initialize(client, opts)
        @client = client
        @event_set = opts.fetch(:event_set)
      end

      def fetch
        @client.fetch(:rsvps, event_id: event_ids) if event_ids && event_ids.length > 0
      end

      def event_ids
        @event_set.members.andand.join ','
      end
    end
  end
end
