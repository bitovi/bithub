require 'events/mappings'
require 'events/protocol'

module Events
  module Dispatcher

    def self.dispatch(payload, feed_name = nil)
      feed_name ||= self.meta_feed(payload)
      Events.feed(feed_name).type(extract_source_data(payload)).new(payload)
    end

    def self.extract_source_data(payload)
      (sd = (payload['source_data'] || payload[:source_data])) ? sd : payload;
    end

    def self.meta_type(payload)
      (payload['meta'].andand['type'] || payload[:meta].andand[:type])
    end
    
    def self.meta_feed(payload)
      (payload['meta'].andand['feed'] || payload[:meta].andand[:feed])
    end
  end
end

Dir.glob('app/domain/events/feeds/*/*.rb').each { |f| require f }
