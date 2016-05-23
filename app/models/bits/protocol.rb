require 'bits/errors'
require 'bits/traits/groupable'
require 'bits/traits/normalizable'
require 'bits/traits/persistable'
require 'bits/traits/routeable'

Dir[File.join('app', 'models', 'wrappers', '**', '*.rb')].each do |f|
  require f.gsub('app/models/', '')
end

module Bits
  class Protocol
    extend Forwardable
    def_delegators :@event, :tenant_name, :brand_id, :hub_id, :service_id

    include Groupable
    include Normalizable
    include Persistable
    include Routable

    def initialize(event)
      @event = event
    end
    attr_reader :event

    def procure
      @instance = (e = find) ? e : build
      self
    end
    attr_reader :instance

    def build
      Bit.new(data)
    end

    def rebuild
      update
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
      Bit.origin_author(uid)
    end

    def nice_name
      self.class.name.gsub(/^Bits::.*::/, '')
    end

    def feed_name
      @feed_name ||= feed_and_type_name[0]
    end

    def type_name
      @type_name ||= feed_and_type_name[1]
    end

    def repr_for_logs
      "#{tenant_name},#{hub_id},#{service_id},#{feed_name},#{type_name}"
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
