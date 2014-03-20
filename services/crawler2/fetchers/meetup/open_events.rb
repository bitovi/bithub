require_relative 'client'

module Fetchers
  module Meetup

    class OpenEvents
      include Client

      def fetch
        @client.fetch(:open_events)
      end
    end

  end
end
