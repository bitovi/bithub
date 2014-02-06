require_relative 'types/event'
require_relative 'types/rsvp'

module Events
  module Meetup
    class Event < Protocol; end
    class Rsvp < Protocol; end

    def self.type(source_data)
      if source_data['rsvp_id']
        Events::Meetup::Rsvp
      elsif source_data['event_url']
        Events::Meetup::Event
      end
    end

    class Processor
      def initialize(response)
        @response = response
      end

      def parse
        @parsed ||= Yajl::Parser.parse(@response)
      end

      def extract
        @extracted ||= parse['results']
      end

      def decorate
      end
    end

  end
end
