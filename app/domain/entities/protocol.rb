require_relative 'traits/determinable'
require_relative 'traits/groupable'
require_relative 'traits/normalizable'
require_relative 'traits/persistable'
require_relative 'traits/referencable'

module Entities

  class EntityError < Exception
    attr_accessor :context
    def initialize(message = nil, context = nil)
      super(message)
      self.context = context
    end
  end

  class MappingError < EntityError; end
  class UpdatingError < EntityError; end
  class NormalizationError < EntityError; end

  class Protocol
    include Determinable
    include Groupable
    include Normalizable
    include Persistable
    include Loggable

    attr_reader :instance

    def initialize(payload)
      initialize_logger("DEBUG")
      @payload = payload
    end

    def procure
      @instance = (e = find) ? e : build
      @instance.props.symbolize_keys!
      self
    end

    def update_if_found
      update unless @instance.new_record?
      self
    end

    def update
      fail UpdatingError.new('Trying to update a new record', @instance) if @instance.new_record?
    end

    def find_by_origin_uid(uid)
      Entity.where("props -> 'origin_author_id' = ?", uid)
    end

    def nice_name
      self.class.name.gsub(/^Entities::.*::/, '')
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
