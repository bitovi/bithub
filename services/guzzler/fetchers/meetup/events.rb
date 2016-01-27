require_relative 'common'

module Guzzler::Fetchers

  module Meetup
    class Events
      include Protocol
      include Meetup::Common

      def initialize(service)
        @service = service
      end

      def fetch
        log_fetch

        handle_errors do
          events = client.fetch :events, group_id: group_ids, status: "upcoming,past", fields: "event_hosts"

          Guzzler.redis do |conn|
            conn.sadd event_ids_cache, ids(events)
          end

          events
        end
      end

      # todo events that can be looked up in redis <3

      private

      def group_id
        @service.config.fetch(:id)
      end

      def group_ids
        [group_id].join(',')
      end

      def ids(events)
        events.map { |el| el.id }
      end
    end
  end
end
