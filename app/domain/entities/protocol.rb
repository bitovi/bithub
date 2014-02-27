require_relative 'errors'
require_relative 'traits/determinable'
require_relative 'traits/groupable'
require_relative 'traits/normalizable'
require_relative 'traits/persistable'
require_relative 'traits/referencable'
require_relative 'traits/validatable'

module Entities
  module Bithub; end
  module Blog; end
  module Disqus; end
  module Forum; end
  module Github; end
  module Irc; end
  module Meetup; end
  module Twitter; end
  module StackExchange; end

  class Protocol
    include Validatable
    include Determinable
    include Groupable
    include Normalizable
    include Persistable
    include Loggable

    attr_reader :instance

    def initialize(payload)
      @payload = payload
      @event = @payload
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
    
    def collect_methods(regexp)
      (self.private_methods + self.methods + self.class.instance_methods(false))
        .select {|m| m.match(regexp)}
        .uniq
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
require_relative 'feeds/stack_exchange/stack_exchange'
