require_relative 'common'

module Guzzler::Fetchers

  module Meetup
    class Rsvps
      include Protocol
      include Meetup::Common

      def initialize(job)
        @job = job
      end

      def fetch
        log_fetch

        handle_errors do
          client.fetch(:rsvps, event_id: event_ids) if event_ids && event_ids.length > 0
        end
      end

      def event_ids
        event_set = nil

        Guzzler.redis do |conn|
          event_set = conn.smembers event_ids_cache
        end

        event_set ? event_set.join(',') : nil
      end

    end
  end
end
