module Events
  module Constructable
    class InvalidDigestSeed < Exception; end
    include Comparable
    include CoreHelpers

    def initialize(payload)
      @data = symbolize_keys(payload)
    end

    def feed
      @feed ||= module_and_class_names[0]
    end

    def type
      @type ||= module_and_class_names[1]
    end
    
    def origin_ts
      origin_timestamp
    end
    
    def origin_timestamp_iso
      origin_timestamp.iso8601
    end

    private
    
    def module_and_class_names
      _, feed, type = self.class.name.match(/.*::(.*)::(.*)/).to_a
      [feed, type]
    end
  end
end
