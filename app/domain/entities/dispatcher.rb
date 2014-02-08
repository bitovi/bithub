require 'entities/mappings'
require 'entities/protocol'

module Entities
  module Dispatcher
    def self.dispatch(event)
      entityType = Entities.feed(event.feed_name).type(event)
      entityType.new(event) unless entityType.nil?
    end
  end
end
