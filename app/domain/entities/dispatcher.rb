require 'entities/mappings'
require 'entities/protocol'

module Entities
  module Dispatcher
    def self.dispatch(event)
      Entities.feed(event.feed_name).type(event).new(event)
    end
  end
end
