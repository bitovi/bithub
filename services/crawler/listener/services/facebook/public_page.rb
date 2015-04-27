require 'koala'

module Supervisors::Services::Facebook
  class PublicPage

    def boot
      items = preloaded_items
      if items.empty?
        notify_frontend owner_data
      else
        publish items, owner_data
      end
    end

    private

    def publish(events, owner_data)
      Actor[:event_publisher].publish events, owner_data
    end

    def page_id
      service_config.fetch(:id)
    end

    def client
      @client ||= Koala::Facebook::API.new service_config.fetch(:access_token)
    end

    def preloaded_items
      Fetchers::Facebook::GetFeed.fetch client, page_id
    end

    # todo: unify with poller
    def notify_frontend(owner_data)
      notif = {
        meta: {
          brand_name: owner_data.brand.name,
          embed_id: owner_data.embed.id
        },
        payload: {
          service: {
            id: owner_data.service.id,
            empty_results: true,
          }
        }
      }
      Actor[:notification_publisher].publish_to_frontend notif
    end

  end
end
