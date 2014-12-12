module Entities
  module Routable
    def route
      route_embed
    end

    def route_embed
      if embed_id && (e = Embed.find_by_id(embed_id))
        e.make_link_to(@instance)
      end
    end
  end
end
