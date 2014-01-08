module Events
  module Constructable
    def initialize(payload)
      @data = payload
    end

    def source_data
      @data.andand[:source_data]
    end

    def meta
      @data.andand[:meta]
    end
    
    def feed
      meta.andand[:feed]
    end

    def type
      meta.andand[:type]
    end
    
    def origin_timestamp_iso
      origin_timestamp.iso8601
    end
  end
end
