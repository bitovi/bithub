module Events
  module Constructable
    class InvalidDigestSeed < Exception; end
    include Comparable
    include CoreHelpers

    def initialize(payload)
      if payload[:source_data]
        @data = payload
      else
        @data = { source_data: symbolize_keys(payload) }
      end
    end

    def source_data
      @data.andand[:source_data]
    end

    def meta
      @data.andand[:meta]
    end
    
    def raw
      @data
    end
    
    def feed
      feed, _ = module_and_class_names
      feed.snake_case
      # meta.andand[:feed]
    end

    def type
      _, type = module_and_class_names
      type.snake_case
      # meta.andand[:type]
    end
    
    def content_digest
      if respond_to? :origin_id
        @digest ||= calc_digest(origin_id.to_s)
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
    
    def module_and_class_names
      _, feed, type = self.class.name.match(/.*::(.*)::(.*)/).to_a
      [feed, type]
    end
  end
end
