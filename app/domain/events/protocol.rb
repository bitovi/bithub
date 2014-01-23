require 'lib/configurable'

require_relative 'traits/persistable'
require_relative 'traits/comparable'
require_relative 'traits/digestable'
require_relative 'traits/jsonable'

module Events
  class InitializationError < Exception; end
  class BuildingError < Exception; end
  class MappingError < Exception; end
  class InvalidDigestSeed < Exception; end

  class Protocol
    include CoreHelpers
    include Persistable
    include Digestable
    include JSONable

    def initialize(payload)
      raw_data = symbolize_keys(payload)
      @data = {}
      @data[:source_data] = (sd = raw_data[:source_data]) ? sd : raw_data
    end

    def source_data
      @data.andand[:source_data]
    end

    def meta
      @data.andand[:meta]
    end

    def ==(other)
      @data == other
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
    
    def module_and_class_names
      _, feed, type = self.class.name.match(/.*::(.*)::(.*)/).to_a
      [feed, type]
    end

  end
end
