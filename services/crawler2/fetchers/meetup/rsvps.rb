require_relative 'client'

module Fetchers
  module Meetup

    class Rsvps
      include Client

      def fetch
        @client.fetch(:rsvps)
      end
    end

  end
end
