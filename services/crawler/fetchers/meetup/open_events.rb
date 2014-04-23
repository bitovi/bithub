module Fetchers
  module Meetup

    class OpenEvents
      include Protocol

      def initialize(client, opts = {})
        @client = client
        @terms = opts.fetch(:terms)
      end

      def fetch
        events = @client.fetch :open_events, text: search_params
        events.map {|e| e.to_h}
      end

      def search_params
        @terms.join ','
      end
    end
  end
end
