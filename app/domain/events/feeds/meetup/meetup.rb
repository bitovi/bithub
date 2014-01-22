require_relative 'types/event'

module Events
  module Meetup
    class Event < Protocol; end

    def self.type(type_name)
      Events::Meetup::Event
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
