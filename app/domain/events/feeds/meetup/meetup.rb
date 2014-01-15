require 'events/feeds/meetup/types/event'

module Events
  module Meetup

    class Processor
      def determine_event_type(original_hash)
        "Event"
      end

      def events_from_response(response)
        response['results']
      end
    end

  end
end
