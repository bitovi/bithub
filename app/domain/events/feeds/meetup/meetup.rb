require 'events/feeds/meetup/types/event'

module Events
  module Meetup
    class Event; end

    def self.type(type_name)
      Events::Meetup::Event
    end

    class Processor
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

      def tags
        #tags: [@config.andand[:term]],
      end
    end

  end
end
