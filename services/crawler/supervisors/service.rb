require 'fetchers/all'

module Supervisors
  module Services; end

  class Service
    include Celluloid
    include Propagation

    def initialize(path, service_info)
      @path = SupervisionNode.new(path, service_info)
      boot
    end

    def boot
      Celluloid.logger.info "Booting S #{@path.actor_name}"
    end

    def execute_cmd(action)
      raise "Executing command on service level. Very bad. This is wrong!"
    end

    private

    def _childs; @endpoints; end

    def static_config
      Actor[:configurator].static_config
    end

    def service_config
      Actor[:configurator].service_config(*@path.rootless).fetch(:config)
    end

    def token
      service_config[:access_token] || service_config[:token]
    end
  end
end
