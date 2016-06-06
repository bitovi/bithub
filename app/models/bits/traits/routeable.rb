module Bits
  module Routable

    def route_to_hub
      if hub_id && (hub = Hub.find_by_id(hub_id))
        hub.make_link_to(@instance)
        route_to_service
      end
    end
    alias_method :route, :route_to_hub

    def route_to_service
      if service_id && (service = Service.find_by_id(service_id))
        if (link = service.make_link_to(@instance))
          service.mark_as_loaded
          service.service_errors.destroy_all # if something is being saved, then service must be working
          Notifier.notify_client(:bit_routed_to_service, { service: service })
          Notifier.notify_client(:bit_persisted, { bit: @instance })
        end
      end
    end
  end
end
