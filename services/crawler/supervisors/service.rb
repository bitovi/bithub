require 'fetchers/all'

module Supervisors
  module Services; end

  class Service
    include Celluloid
    include Propagation

    def initialize(path, service_info)
      @path = SupervisionNode.new(path, service_info)
      @endpoints = SupervisionGroup.new
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
