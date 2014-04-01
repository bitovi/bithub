require 'rmeetup'

module Fetchers
  module Meetup

    class OpenEvents
      include Protocol

      def initialize(client, opts = {})
        @client = client
        @text_search = opts.fetch(:terms).join(',')
      end

      def fetch
        @client.fetch(:open_events, {text: @text_search, sign: 'true'})
      end
    end
  end
end
