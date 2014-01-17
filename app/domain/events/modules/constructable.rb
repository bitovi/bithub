module Events
  module Constructable
    class InvalidDigestSeed < Exception; end
    include Comparable
    include CoreHelpers

    def initialize(payload)
      @data = symbolize_keys(payload)
    end

    def source_data
      @data
    end

    def feed
      @feed ||= module_and_class_names[0]
    end

    def type
      @type ||= module_and_class_names[1]
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
