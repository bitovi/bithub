require_relative 'traits/persistable'
require_relative 'traits/comparable'
require_relative 'traits/digestable'
require_relative 'traits/jsonable'

module Events
  class EventException < Exception
    attr_accessor :source_data

    def initialize(message = nil, source_data = nil)
      super(message)
      self.source_data = source_data
    end
  end

  class InitializationError < EventException; end
  class BuildingError < EventException; end
  class MappingError < EventException; end
  class InvalidDigestSeed < EventException; end

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
    
    def feed_name
      @feed_name ||= module_and_class_names[0]
    end

    def type_name
      @type_name ||= module_and_class_names[1]
    end

    def origin_ts
      origin_timestamp
    end
    
    def origin_timestamp_iso
      origin_timestamp.iso8601
    end
    
    def module_and_class_names
      _, @feed_name, @type_name = self.class.name.match(/.*::(.*)::(.*)/).to_a
      [@feed_name, @type_name]
    end
  end
end

require 'events/feeds/bithub/bithub'
require 'events/feeds/github/github'
require 'events/feeds/twitter/twitter'
require 'events/feeds/disqus/disqus'
require 'events/feeds/forum/forum'
require 'events/feeds/blog/blog'
require 'events/feeds/irc/irc'
require 'events/feeds/meetup/meetup'
