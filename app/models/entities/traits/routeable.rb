module Entities
  module Routable
    def route
      route_embed
    end

    def route_embed
      if embed_name && (e = Embed.find_by_name(embed_name))
        e.make_link_to(@instance)
      end
    end
  end
end
