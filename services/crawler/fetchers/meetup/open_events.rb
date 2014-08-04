module Fetchers
  module Meetup

    class OpenEvents
      include Protocol

      def initialize(client, opts = {})
        @client = client
        @terms = opts.fetch(:terms)
      end

      def fetch
        Celluloid.logger.info "Searching Meetup open_events with #{search_params}"
        events = @client.fetch :open_events, { text: search_params, fields: "event_hosts" }

        events.map {|e| e.to_h}
      end

      def search_params
        @terms.join ', '
      end
    end
  end
end
