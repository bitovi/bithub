require_relative 'support/propagation'
require_relative 'support/supervision_node'
require_relative 'brand'

module Supervisors
  class Main
    include Celluloid
    include Propagation

    def initialize
      @path = SupervisionNode.new(nil, MainNode.new)
      boot
    end

    def boot
      Celluloid.logger.info "Booting M #{@path.actor_name}"
      @brands = SupervisionGroup.new
      config.fetch(:brands).each do |b|
        bi = BrandInfo.new(b.fetch(:id), b.fetch(:name))
        start_brand_supervisor(bi)
      end
    end

    def start_brand_supervisor(bi)
      @brands.supervise_as(
        @path.next_level(bi).actor_name,
        Supervisors::Brand,
        *[@path, bi]
      )
    end

    def stop_brand_supervisor(bi)
      Celluloid.logger.info "Killing B #{@path.next_level(bi).actor_name}"
      if (a = Actor[@path.next_level(bi).actor_name])
        a.terminate_cascading
      end
    end

    def execute_cmd(target, action)
      if action == :stop
        stop_brand_supervisor(target.node)
      elsif action == :start
        start_brand_supervisor(target.node)
      elsif action == :restart
        stop_embed_supervisor(target.node)
        start_embed_supervisor(target.node)
      end
    end

    private

    def _childs; @brands; end

    def config
      Actor[:configurator].config
    end
  end
end
