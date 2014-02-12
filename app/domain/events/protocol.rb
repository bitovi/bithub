require_relative 'errors'
require_relative 'traits/persistable'
require_relative 'traits/serializable'

module Events
  module Github; end
  module Twitter; end
  module Forum; end
  module Blog; end
  module Disqus; end
  module Bithub; end
  module Meetup; end
  module Irc; end

  class Protocol
    include CoreHelpers
    include Persistable
    include Serializable
    include Loggable

    attr_reader :instance

    def initialize(payload)
      initialize_logger("DEBUG")
      raw_data = symbolize_keys(payload)
      @data = (sd = raw_data[:source_data]) ? sd : raw_data;
    end

    def content_digest
      if respond_to?(:event_id)
        calc_digest(event_id.to_s)
      elsif respond_to?(:origin_id)
        calc_digest(origin_id.to_s)
      else
        fail BuildingError.new("Couldn't calculate digest. Probably missing a seed.", nice_name)
      end
    end

    def calc_digest(seed)
      @digest ||= (seed.nil?) ? nil : Digest::MD5.hexdigest(seed + self.class.name)
    end

    def source_data
      @data
    end

    def feed_name
      @feed_name ||= module_and_class_names[0]
    end

    def type_name
      @type_name ||= module_and_class_names[1]
    end

    def type_name_sym
      type_name.to_sym
    end
    
    def ==(other)
      @data == other
    end

    def origin_ts
      origin_timestamp
    end
    
    def origin_timestamp_iso
      origin_timestamp.iso8601
    end

    def referenced_issue_numbers 
      []
    end
    
    def nice_name
      self.class.name.gsub(/^Events::.*::/, '')
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
