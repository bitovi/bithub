require_relative 'common'

module Guzzler::Fetchers

  module Meetup
    class OpenEvents
      include Protocol
      include Meetup::Common

      def initialize(service)
        @service = service
      end

      def fetch
        log_fetch

        handle_errors do
          events = client.fetch :open_events, { text: search_params, status: "upcoming", fields: "event_hosts" }
          events.map { |e| e.to_h }
        end
      end

      def search_params
        @service.config.fetch(:terms).join ', '
      end
      
    end
  end
end
