module Fetchers
  module Meetup

    class OpenEvents
      include Protocol

      def initialize(client, opts = {})
        @client = client
        @terms = opts.fetch(:terms)
      end

      def fetch
        @client.fetch :open_events, text: @text_search
      end

      def search_params
        @terms.join ','
      end
    end
  end
end
