require 'entities/mappings'
require 'entities/protocol'

module Entities
  module Dispatcher
    def self.dispatch(event)
      unless event.kind_of? Events::Protocol
        fail Entities::MappingError.new('Dispatcher requires an Event instance to dispatch propertly', event)
      end

      Entities.feed(event.feed_name).type(event).new(event)
    end
  end
end
