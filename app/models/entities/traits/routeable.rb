module Entities
  module Routable
    def route
      route_embed
      route_service
    end

    def route_embed
      if embed_id && (e = Embed.find_by_id(embed_id))
        e.make_link_to(@instance)
      end
    end

    def route_service
      if service_id && (s = Service.find_by_id(service_id))
        s.make_link_to(@instance)
        s.errors.destroy_all # if something is being saved, then service must be working
      end
    end
  end
end
