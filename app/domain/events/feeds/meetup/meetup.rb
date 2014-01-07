require 'events/feeds/meetup/types/event'

module Events
  module Meetup

    class Processor
      def initialize
        config = {}
        @config = yield config if block_given?
      end
    end

  end
end
