module Entities
  module Routable
    include ::RabbitHelper::Sugar

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
        notify_client
      end
    end

    def notify_client
      x('x.liveservice', chan_is_short_lived = true) do |xchange|
        xchange.publish(JSON.generate(client_msg), routing_key: 'services')
      end
    end

    def client_msg
      {
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
      }
    end
  end
end
