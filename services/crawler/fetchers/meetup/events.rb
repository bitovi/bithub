require 'rmeetup'

module Fetchers
  module Meetup

    class Events
      include Protocol

      def initialize(client, opts)
        @client = client
        @group_ids = opts.fetch(:group_ids)
      end

      def set_tracked_events(event_ids)
        @event_ids = event_ids
      end

      def fetch
        @client.fetch :events, group_id: group_ids
      end

      private
      def group_ids
        @group_ids.join(',')
      end
    end
  end
end
