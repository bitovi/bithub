require_relative 'embed'

module Supervisors
  class Brand
    include Celluloid
    include Propagation

    def initialize(path, bn)
      @path = TreePath.new(path, @brand_name = bn, :brand_name)
      Celluloid.logger.info "Booting #{@path.actor_name}"
      boot
    end

    def boot
      @embeds = SupervisionGroup.new
      brand_config.fetch(:embeds).each do |e|
        start_embed_supervisor(e.fetch(:name))
      end
    end

    def start_embed_supervisor(embed_name)
      @embeds.supervise_as(
        @path.child_actor_name(embed_name),
        Supervisors::Embed,
        *[@path, embed_name]
      )
    end

    def stop_embed_supervisor(embed_name)
      if (a = Actor[@path.child_actor_name(embed_name)])
        a.terminate
      end
    end
    
    def execute_cmd(path, action)
      if action == :stop
        stop_embed_supervisor(path.embed_name)
      end
    end
    
    private
    
    def _childs; @embeds; end

    def brand_config
      Celluloid::Actor[:configurator].brand_config(*@path.rootles_path)
    end
  end
end
