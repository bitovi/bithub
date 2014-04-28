module Fetchers
  module Meetup

    class Events
      include Protocol

      def initialize(client, opts)
        @client = client
        @group_ids = opts.fetch(:group_ids)
      end

      def fetch
        @client.fetch :events, group_id: group_ids, status: "upcoming,past", fields: "event_hosts"
      end

      # todo events that can be looked up in redis <3

      private

      def group_ids
        @group_ids.join ','
      end
    end
  end
end
