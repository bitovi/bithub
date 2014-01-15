require 'events/feeds/meetup/types/event'

module Events
  module Meetup
    def self.type(type_name)
      self.const_get(type_name)
    end

    class Processor
      attr_reader :parsed, :extracted

      def initialize(response)
        @response = response
        @config = yield if block_given?
      end

      def parse
        @parsed ||= Yajl::Parser.parse(@response)
      end

      def extract
        @extracted ||= parse['results']
      end

      def determine_event_type(original_hash)
        "Event"
      end
      
      def tags
        #tags: [@config.andand[:term]],
      end
    end

  end
end
