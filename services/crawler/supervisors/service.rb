require_relative 'common'

module Supervisors
  class Service
    include Celluloid
    include Common

    def initialize(bn, en, sn)
      @current_level = [@brand_name = bn, @embed_name = en, @service_name = sn]
      Celluloid.logger.info "Booting #{@current_level}"
      boot
    end

    private

    def service_config
      Celluloid::Actor[:configurator].service_config(@brand_name, @embed_name, @service_name)
    end
  end
end

require_relative 'services/all'
