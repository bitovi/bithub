require 'lib/core_helpers'
require 'events/mappings'

module Events
  class Payload
    include CoreHelpers
    attr_reader :feed_name
    
    def initialize(payload, feed_name = nil)
      @feed_name = feed_name || meta_feed(payload)
      @event = construct_event(extract_source_data(payload))
    end

    def method_missing(method, *args, &block)
      @event.send(method, *args, &block)
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
    
    def construct_event(payload)
      Events.feed(@feed_name).type(payload).new(payload)
    end
  end
end

require 'events/modules/constructable'
Dir.glob('app/domain/events/feeds/*/*.rb').each { |f| require f }
