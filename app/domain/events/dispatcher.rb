require 'events/mappings'
require 'events/protocol'

module Events
  module Dispatcher

    def self.dispatch(payload, feed_name = nil)
      feed_name ||= self.meta_feed_name(payload)
      Events.feed(feed_name).type(extract_source_data(payload)).new(payload)
    end

    def self.extract_source_data(payload)
      (sd = (payload['source_data'] || payload[:source_data])) ? sd : payload;
    end

    def self.meta_type_name(payload)
      (payload['meta'].andand['type_name'] || payload[:meta].andand[:type_name])
    end
    
    def self.meta_feed_name(payload)
      (payload['meta'].andand['feed_name'] || payload[:meta].andand[:feed_name])
    end
  end
end
