require 'poller'
require 'fetchers/all'

module Supervisors
  class Service
    include Celluloid
    include Propagation

    def initialize(path, service_info)
      @path = SupervisionNode.new(path, service_info)
      Celluloid.logger.info "Booting #{@path.actor_name}"
      boot
    end

    def execute_cmd(action)
      Celluloid.logger.debug "YOU SHOULDN'T EVER BE HERE"
    end

    private

    def static_config
      Actor[:configurator].static_config
    end

    def service_config
      Actor[:configurator].service_config(*@path.rootless)
    end

    def token
      service_config[:access_token] || service_config[:token]
    end
  end
end

module Supervisors
  module Services; end
end

require_relative 'services/all'
