require 'lib/core_helpers'
require 'events/mappings'

module Events
  module Dispatcher

    def self.construct_event(payload, feed_name = nil)
      feed_name ||= self.meta_feed(payload)
      sd = extract_source_data(payload)
      Events.feed(feed_name).type(sd).new(sd)
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

require 'events/modules/constructable'
Dir.glob('app/domain/events/feeds/*/*.rb').each { |f| require f }
