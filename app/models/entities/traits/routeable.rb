module Entities
  module Routable

    def route_to_embed
      if embed_id && (embed = Embed.find_by_id(embed_id))
        embed.make_link_to(@instance)
        route_to_service
      end
    end
    alias_method :route, :route_to_embed

    def route_to_service
      if service_id && (service = Service.find_by_id(service_id))
        if (link = service.make_link_to(@instance))
          service.mark_as_loaded
          service.service_errors.destroy_all # if something is being saved, then service must be working
          Notifier.notify_client(:entity_routed_to_service, { service: service })
          Notifier.notify_client(:entity_persisted, { entity: @instance })
        end
      end
    end
  end
end
