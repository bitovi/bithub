require 'entities/errors'
require 'entities/traits/groupable'
require 'entities/traits/normalizable'
require 'entities/traits/persistable'
require 'entities/traits/routeable'

Dir[File.join('app', 'models', 'wrappers', '**', '*.rb')].each do |f|
  require f.gsub('app/models/', '')
end

module Entities
  class Protocol
    extend Forwardable
    def_delegators :@event, :brand_id, :embed_id, :service_id

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

    def build
      Entity.new(data)
    end

    def rebuild
      @instance.assign_attributes(data)
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

    def repr_for_logs
      "#{brand_id},#{embed_id},#{embed_id},#{feed_name},#{type_name}"
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
