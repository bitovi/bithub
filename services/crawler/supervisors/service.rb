module Supervisors
  class Service
    include Celluloid

    def initialize(path, si)
      @path = TreePath.new(path, @service_info = si, :service_info)
      Celluloid.logger.info "Booting #{@path.actor_name}"
      boot
    end

    private

    def static_config
      Celluloid::Actor[:configurator].static_config
    end

    def service_config
      Celluloid::Actor[:configurator].service_config(*@path.rootles_path)
    end

    def token
      service_config[:access_token] || service_config[:token]
    end
  end
end

require_relative 'services/all'
