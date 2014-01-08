module Events
  class Payload

    def initialize(payload)
      @event = construct_event(payload)
    end

    def method_missing(method, *args, &block)
      @event.send(method, *args, &block)
    end
    
    def construct_event(payload)
      feed = payload.andand[:meta].andand[:feed].capitalize
      type = payload.andand[:meta].andand[:type].capitalize
      fail UnknownFeedError if !feed
      fail UnknownTypeError if !type
      Events.const_get(feed).const_get(type).new(payload)
    end
  end
end
