require 'events/errors'
require 'events/traits/persistable'
require 'events/traits/serializable'
require 'events/traits/validatable'
require 'events/traits/normalizable'

# require Wrappers
Dir[File.join('app', 'models', 'wrappers', '**', '*.rb')].each do |f|
  require f.gsub('app/models/', '')
end

module Events
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
    include CoreHelpers
    include Persistable
    include Normalizable
    include Serializable
    include Validatable

    def initialize(source_data, meta = {}, instance = nil)
      @source_data = symbolize_keys(source_data)
      @meta = symbolize_keys(meta)
      @instance = instance
      wrap_response if self.respond_to? :wrap_response
    end
    attr_reader :instance, :source_data, :meta


    def build
      return self if @instance

      unless ::Service.find_by_id(service_id)
        fail OrphanedEventError.new('Event to be saved under a service that has already been deleted.')
      end

      unless ::Embed.find_by_id(embed_id)
        fail OrphanedEventError.new('Event to be saved under an embed that has already been deleted.')
      end

      @instance = ::Event.new({
        content_digest: content_digest,
        source_data: source_data,
        embed_id: embed_id,
        service_id: service_id,
        props: meta || {}
      })

      self
    end

    def content_digest
      if respond_to?(:digest_seed)
        Digest::MD5.hexdigest(digest_seed)
      else
        fail BuildingError.new("Don't know how to build a digest seed.", nice_name)
      end
    end

    def feed_name
      @feed_name ||= feed_and_type_name[0]
    end

    def type_name
      @type_name ||= feed_and_type_name[1]
    end

    def embed_name
      @meta.fetch(:embed_name)
    end

    def tenant_name
      @meta.fetch(:tenant_name)
    end
    
    def brand_id
      @meta.fetch(:brand_id)
    end
    
    def embed_id
      @meta.fetch(:embed_id)
    end
    
    def service_id
      @meta.fetch(:service_id)
    end

    def ==(other)
      @source_data == other
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

    def collect_methods(regexp)
      (self.private_methods + self.methods + self.class.instance_methods(false))
        .select {|m| m.match(regexp)}
        .uniq
    end
    
    def repr_for_logs
      "#{tenant_name},#{embed_id},#{service_id},#{feed_name},#{type_name}"
    end

    private
    def feed_and_type_name
      _, @feed_name, @type_name = self.class.name.match(/.*::(.*)::(.*)/).to_a
      [@feed_name, @type_name]
    end
  end
end
