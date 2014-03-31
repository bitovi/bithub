require 'rmeetup'

module Fetchers
  module Meetup

    class OpenEvents
      def initialize(client, opts = {})
        @client = client
        @interval = opts.fetch(:interval) { 10 }
        @text_search = opts.fetch(:terms).join(',')
      end
      attr_reader :interval

      def fetch
        @client.fetch(:open_events, {text: @text_search, sign: 'true'})
      end
    end

  end
end
