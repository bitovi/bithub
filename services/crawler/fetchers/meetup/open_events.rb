module Fetchers
  module Meetup

    class OpenEvents
      include Protocol

      def initialize(client, opts = {})
        @client = client
        @terms = opts.fetch(:terms)
      end

      def fetch
        handle_errors do
          events = @client.fetch :open_events, { text: search_params, status: "upcoming", fields: "event_hosts" }
          events.map {|e| e.to_h}
        end
      end

      def search_params
        @terms.join ', '
      end
    end
  end
end
