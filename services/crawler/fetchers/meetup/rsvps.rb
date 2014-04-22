require 'rmeetup'

module Fetchers
  module Meetup

    class Rsvps
      include Protocol

      def initialize(client)
        @client = client
      end

      def fetch
        @client.fetch :rsvps, event_id: event_ids
      end

      def event_ids
        # todo fetch from redis
      end
    end
  end
end
