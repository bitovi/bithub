require_relative 'common'

module Guzzler::Fetchers

  module Meetup
    class OpenEvents
      include Protocol
      include Meetup::Common

      def initialize(job)
        @job = job
      end

      def fetch
        log_fetch

        handle_errors do
          events = client.fetch :open_events, { text: search_params, status: "upcoming", fields: "event_hosts" }
          events.map { |e| e.to_h }
        end
      end

      def search_params
        @job.config.fetch('terms').join ', '
      end
      
    end
  end
end
