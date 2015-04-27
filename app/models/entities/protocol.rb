require 'entities/errors'
require 'entities/traits/determinable'
require 'entities/traits/groupable'
require 'entities/traits/normalizable'
require 'entities/traits/persistable'
require 'entities/traits/validatable'
require 'entities/traits/routeable'

Dir[File.join('app', 'models', 'wrappers', '**', '*.rb')].each do |f|
  require f.gsub('app/models/', '')
end

module Entities

  module Disqus; end
  module Github; end
  module Twitter; end
  module Meetup; end
  module Stackexchange; end
  module Facebook; end
  module Instagram; end
  module Tumblr; end
  module Foursquare; end
  module Rss; end

  class Protocol
    include Validatable
    include Determinable
    include Groupable
    include Normalizable
    include Persistable
    include Routable

    def initialize(payload)
      @payload = payload
      @event = @payload
    end
    attr_reader :event

    def procure
      @instance = (e = find) ? e : build
      self
    end
    attr_reader :instance

    def update_if_found
      update unless @instance.new_record?
      self
    end

    def update
      fail UpdatingError.new('Trying to update a new record', @instance) if @instance.new_record?
    end

    def find_by_origin_uid(uid)
      Entity.origin_author(uid)
    end

    def nice_name
      self.class.name.gsub(/^Entities::.*::/, '')
    end

    def feed_name
      @feed_name ||= feed_and_type_name[0]
    end

    def type_name
      @type_name ||= feed_and_type_name[1]
    end

    def embed_name
      @event.embed_name
    end

    def embed_id
      @event.embed_id
    end

    def service_id
      @event.service_id
    end

    def collect_methods(regexp)
      (self.private_methods + self.methods + self.class.instance_methods(false))
        .select {|m| m.match(regexp)}
        .uniq
    end

    private
    def feed_and_type_name
      _, @feed_name, @type_name = self.class.name.match(/.*::(.*)::(.*)/).to_a
      [@feed_name, @type_name]
    end

  end
end

require_relative 'feeds/disqus/disqus'
require_relative 'feeds/github/github'
require_relative 'feeds/twitter/twitter'
require_relative 'feeds/meetup/meetup'
require_relative 'feeds/stackexchange/stackexchange'
require_relative 'feeds/facebook/facebook'
require_relative 'feeds/rss/rss'
require_relative 'feeds/foursquare/foursquare'
require_relative 'feeds/instagram/instagram'
require_relative 'feeds/tumblr/tumblr'
