require_relative 'support/propagation'
require_relative 'support/supervision_node'
require_relative 'brand'

module Supervisors
  class Main
    include Celluloid
    include Propagation

    def initialize
      @path = SupervisionNode.new(nil, MainNode.new)
      Celluloid.logger.info "Booting #{@path.actor_name}"
      boot
    end

    def boot
      @brands = SupervisionGroup.new
      config.fetch(:brands).each do |b|
        bi = BrandInfo.new(b.fetch(:id), b.fetch(:name))
        start_brand_supervisor(bi)
      end
    end

    def start_brand_supervisor(bi)
      @brands.supervise_as(
        @path.child_actor_name(bi),
        Supervisors::Brand,
        *[@path, bi]
      )
    end

    def stop_brand_supervisor(bi)
      if (a = Actor[@path.child_actor_name(bi.name)])
        a.terminate
      end
    end

    def execute_cmd(target, action)
      if action == :stop
        stop_brand_supervisor(target)
      elsif action == :start
        start_brand_supervisor(target)
      end
    end

    private

    def _childs; @brands; end

    def config
      Actor[:configurator].config
    end
  end
end
