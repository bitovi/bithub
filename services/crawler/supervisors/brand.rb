require_relative 'embed'

module Supervisors
  class Brand
    include Celluloid
    include Propagation

    def initialize(path, brand_info)
      @path = SupervisionNode.new(path, brand_info)
      boot
    end

    def boot
      Celluloid.logger.info "Booting B #{@path.actor_name}"
      @embeds = SupervisionGroup.new
      brand_config.fetch(:embeds).each do |e|
        ei = EmbedInfo.new(e.fetch(:id), e.fetch(:name))
        start_embed_supervisor(ei)
      end
    end

    def start_embed_supervisor(ei)
      @embeds.supervise_as(
        @path.next_level(ei).actor_name,
        Supervisors::Embed,
        *[@path, ei]
      )
    end

    def stop_embed_supervisor(ei)
      Celluloid.logger.info "Killing E #{@path.next_level(ei).actor_name}"
      if (a = Actor[@path.next_level(ei).actor_name])
        a.terminate_cascading
      end
    end

    def execute_cmd(target, action)
      if action == :stop
        stop_embed_supervisor(target.node)
      elsif action == :start
        start_embed_supervisor(target.node)
      elsif action == :restart
        stop_embed_supervisor(target.node)
        start_embed_supervisor(target.node)
      end
    end

    private

    def _childs; @embeds; end

    def brand_config
      Actor[:configurator].brand_config(*@path.rootless)
    end
  end
end
