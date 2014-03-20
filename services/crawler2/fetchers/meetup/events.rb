require_relative 'client'

module Fetchers
  module Meetup

    class Events
      include Client

      def fetch
        @client.fetch(:events)
      end
    end

  end
end
