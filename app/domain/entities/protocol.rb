require_relative 'traits/determinable'
require_relative 'traits/groupable'
require_relative 'traits/normalizable'
require_relative 'traits/persistable'
require_relative 'traits/referencable'

module Entities
  class Protocol

    class DeterminationError < Exception; end
    class NormalizationError < Exception; end
    class BuildingError < Exception; end
    class GroupingError < Exception; end

    include Determinable
    include Groupable
    include Normalizable
    include Persistable
    
    attr_reader :instance

    def initialize(payload)
      @payload = payload
    end

    def procure
      @instance = (e = find) ? e : build
      self
    end
    
    def find_by_origin_uid(uid)
      Entity.where("props -> 'origin_author_id' = ?", uid)
    end

    def feed_name
      self.class.name.match(/::(.+)::/).to_a[1]
    end

    def type_name
      self.class.name.match(/::.*::(.+)$/).to_a[1]
    end

  end
end

require_relative 'feeds/blog/blog'
require_relative 'feeds/disqus/disqus'
require_relative 'feeds/forum/forum'
require_relative 'feeds/github/github'
require_relative 'feeds/twitter/twitter'
require_relative 'feeds/meetup/meetup'
require_relative 'feeds/irc/irc'
require_relative 'feeds/bithub/bithub'
