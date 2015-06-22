require 'events/events'
require 'entities/entities'

module Entities
  class FeedDeterminator
    def initialize(event)
      puts "--------> #{event.class}"
      if !event.kind_of?(Events::Protocol) # || !event.kind_of(Event)
        fail Entities::DeterminationError.new('Determinator requires an Event to work.')
      end
      @event = event
    end

    def feed_module
      if Entities.constants.include?(feed_name)
        Entities.const_get(feed_name)
      else
        fail Entities::DeterminationError.new("Non-existent Entity feed.", feed_name)
      end
    end

    def feed_name
      @event.feed_name.to_sym
    end
  end
end
