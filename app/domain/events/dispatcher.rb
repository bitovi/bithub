require 'events/mappings'
require 'events/protocol'

module Events
  module Dispatcher

    def self.dispatch(payload, feed_name = nil)
      Events
      .feed(feed_name || meta_feed_name(payload))
      .type(extract_source_data(payload))
      .new(payload)
    end

    def self.extract_source_data(payload)
      (sd = (payload['source_data'] || payload[:source_data])) ? sd : payload;
    end
    
    def self.meta_feed_name(payload)
      payload.symbolize_keys.andand[:meta].symbolize_keys.andand[:feed_name]
    end
  end
end
