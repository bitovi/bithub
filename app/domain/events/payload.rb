require 'lib/core_helpers'
require 'events/mappings'

module Events
  class Payload
    class MissingFeedError < Exception; end
    class MissingTypeError < Exception; end
    include CoreHelpers
    
    def initialize(payload)
      fail MissingFeedError unless payload[:meta][:feed]
      fail MissingTypeError unless payload[:meta][:type]
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
