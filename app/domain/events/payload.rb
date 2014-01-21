require 'lib/core_helpers'
require 'events/mappings'

module Events

  class Payload
    class DelegationError < Exception; end
    
    def initialize(payload, feed_name = nil)
      feed_name = feed_name || meta_feed(payload)
      if block_given?
        @event = yield
      else
        construct_event(extract_source_data(payload), feed_name)
      end
    end

    def method_missing(method, *args, &block)
      if @event.respond_to? method
        @event.send(method, *args, &block)
      else
        fail DelegationError, "#{@event_class} doesn't respond to #{method}"
      end
    end

    def extract_source_data(payload)
      (sd = (payload['source_data'] || payload[:source_data])) ? sd : payload;
    end

    def meta_type(payload)
      (payload['meta'].andand['type'] || payload[:meta].andand[:type])
    end
    
    def meta_feed(payload)
      (payload['meta'].andand['feed'] || payload[:meta].andand[:feed])
    end
    
    private
    def construct_event(payload, feed_name)
      @event_class = Events.feed(feed_name).type(payload)
      @event = @event_class.new(payload)
    end
  end
end

require 'events/modules/constructable'
Dir.glob('app/domain/events/feeds/*/*.rb').each { |f| require f }
