require 'koala'

# Facebook realtime API works a bit different from the others
# We have few types of access tokens:
# - user oauth access token (few hours), can be 'long-lived' (~60d)
# - page access token, have no-expiry if are obtained with user long-lived token
#
# First we subscribe our app (Bithub) on the Facebook RealTime API
# to receive notifications about changes on pages feed.
# Next step is to subscribe FB page to the our app (Bithub)
#
# Finally we should recieve notifications containing changes.
# This is the best there is of documentation
# https://developers.facebook.com/docs/graph-api/real-time-updates/v2.2
# https://developers.facebook.com/docs/facebook-login/access-tokens

module Supervisors::Services::Facebook
  class Page < Supervisors::Service

    ### Current hack
    # if there is no (page) access token in service use app token,
    # skip RT subscription and only preload data from the page

    def boot
      begin
        subscribe_page
      rescue Koala::KoalaError => e
        info "Facebook subscription failed with #{e.message}"
      end

      items = preloaded_items
      if items.empty?
        notify_frontend owner_data
      else
        publish items, owner_data
      end
    end

    def cleanup
      unsubscribe_page
    end

    private

    def registry
      Actor[:subscription_registry]
    end

    def publish(events, owner_data)
      Actor[:event_publisher].publish events, owner_data
    end

    def page_id
      service_config.fetch(:id)
    end

    def page_token
      service_config.fetch(:access_token)
    end

    def client
      @client ||= Koala::Facebook::API.new page_token #, app_secret
    end

    def subscribe_page
      client.graph_call "v2.2/#{page_id}/subscribed_apps", {access_token: page_token}, 'post'
      registry.subscribe 'facebook', 'page', page_id, owner_data
    end

    def unsubscribe_page
      registry.unsubscribe 'facebook', 'page', page_id, owner_data
      client.graph_call "v2.2/#{page_id}/subscribed_apps", {access_token: page_token}, 'delete'
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
