require_relative 'support/propagation'
require_relative 'support/service_info'
require_relative 'support/tree_path'
require_relative 'brand'

module Supervisors
  class Main
    include Celluloid
    include Propagation

    def initialize
      @path = TreePath.new(nil, 'main', :root)
      Celluloid.logger.info "Booting #{@path.actor_name}"
      boot
    end

    def boot
      @brands = SupervisionGroup.new
      config.fetch(:brands).each do |b|
        start_brand_supervisor(b.fetch(:name))
      end
    end

    def start_brand_supervisor(brand_name)
      @brands.supervise_as(
        @path.child_actor_name(brand_name),
        Supervisors::Brand,
        *[@path, brand_name]
      )
    end

    def stop_brand_supervisor(brand_name)
      if (a = Actor[@path.child_actor_name(brand_name)])
        a.terminate
      end
    end

    def execute_cmd(target, action)
      if action == :stop
        stop_brand_supervisor(target.brand_name)
      elsif action == :start
        start_brand_supervisor(target.brand_name)
      end
    end

    private

    def _childs; @brands; end

    def config
      Actor[:configurator].config
    end
  end
end
