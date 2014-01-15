module Events
  module Constructable
    class InvalidDigestSeed < Exception; end

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
    
    def content_digest
      if respond_to? :origin_id
        @digest ||= calc_digest(origin_id)
      else
        fail InvalidDigestSeed
      end
    end
    
    def origin_timestamp_iso
      origin_timestamp.iso8601
    end

    private
    def calc_digest(seed)
      Digest::MD5.hexdigest(seed + self.class.name)
    end
    
  end
end
