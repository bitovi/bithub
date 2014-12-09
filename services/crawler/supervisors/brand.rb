require_relative 'embed'

module Supervisors
  class Brand
    include Celluloid
    include Propagation

    def initialize(path, brand_info)
      @path = SupervisionNode.new(path, brand_info)
      Celluloid.logger.info "Booting #{@path.actor_name}"
      boot
    end

    def boot
      @embeds = SupervisionGroup.new
      brand_config.fetch(:embeds).each do |e|
        ei = EmbedInfo.new(e.fetch(:id), e.fetch(:name))
        start_embed_supervisor(ei)
      end
    end

    def start_embed_supervisor(ei)
      @embeds.supervise_as(
        @path.child_actor_name(ei.name),
        Supervisors::Embed,
        *[@path, ei]
      )
    end

    def stop_embed_supervisor(ei)
      if (a = Actor[@path.child_actor_name(ei.name)])
        a.terminate
      end
    end
    
    def execute_cmd(target, action)
      if action == :stop
        stop_embed_supervisor(target)
      elsif action == :start
        start_embed_supervisor(target)
      elsif action == :restart
        stop_embed_supervisor(target)
        start_embed_supervisor(target)
      end
    end
    
    private
    
    def _childs; @embeds; end

    def brand_config
      Actor[:configurator].brand_config(*@path.rootless)
    end
  end
end
