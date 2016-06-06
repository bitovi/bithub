require 'events/events'
require 'bits/bits'

module Bits
  class FeedDeterminator
    def initialize(event)
      if !event.kind_of?(Events::Protocol)
        fail Bits::DeterminationError.new('Determinator requires an Event to work.')
      end
      @event = event
    end

    def feed_module
      if Bits.constants.include?(feed_name)
        Bits.const_get(feed_name)
      else
        fail Bits::DeterminationError.new("Non-existent Bit feed.", feed_name)
      end
    end

    def feed_name
      @event.feed_name.to_sym
    end
  end
end
