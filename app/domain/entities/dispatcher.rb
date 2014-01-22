require 'entities/mappings'
require 'entities/protocol'

module Entities
  module Dispatcher
    def self.dispatch(event)
      Entities.feed(event.feed).type(event.type).new(event)
    end
  end
end
