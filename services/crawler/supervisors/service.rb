require 'fetchers/all'

module Supervisors
  module Services; end

  class Service
    include Celluloid
    include Propagation

    def initialize(path, service_info, opts={})
      @path = SupervisionNode.new(path, service_info)
      @endpoints = SupervisionGroup.new
      @boot_on_init = opts.fetch(:boot_on_init) { true }
      boot if boot_on_init?
    end

    def boot
      fail NotImplementedError.new('must call concrete Service supervisor, this is an ABT')
    end

    def owner_data
      @owner_data ||= OwnerData.new(
        @path.brand.id\
        , @path.brand.name\
        , @path.embed.id\
        , @path.embed.name\
        , @path.service.id\
        , @path.service.feed_name\
        , @path.service.type_name\
        , @path.service.config\
      )
    end

    private

    def _childs; @endpoints; end

    def static_config
      Actor[:configurator].static_config
    end

    def service_config
      @path.service_info.config
    end

    def token
      service_config[:access_token] || service_config[:token]
    end
  end
end
