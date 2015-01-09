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
        s.service_errors.destroy_all # if something is being saved, then service must be working
        Support::LiveserviceNotifier.new.notif({
          meta: {
            brand_name: Apartment::Tenant.current,
            embed_id: embed_id
          },
          payload: {
            service: {
              id: service_id,
              has_errors: false
            }
          }
        }, :services)
      end
    end
  end
end
