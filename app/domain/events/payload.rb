require 'lib/core_helpers'
require 'events/mappings'

module Events
  class Payload
    class InitializationError < Exception; end
    include CoreHelpers
    
    def initialize(payload)
      fail InitializationError, 'missing feed' unless payload.andand[:meta].andand[:feed]
      fail InitializationError, 'missing type' unless payload.andand[:meta].andand[:type]
      @event = construct_event(symbolize_keys(payload))
    end

    def method_missing(method, *args, &block)
      @event.send(method, *args, &block)
    end
    
    def construct_event(payload)
      feed_name = payload.andand[:meta].andand[:feed]
      type_name = payload.andand[:meta].andand[:type]
      Events.feed(feed_name).type(type_name).new(payload)
    end
  end
end

require 'events/modules/constructable'
Dir.glob('app/domain/events/feeds/*/*.rb').each { |f| require f }
