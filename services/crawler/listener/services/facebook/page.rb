require 'koala'
require 'supervisors/support/owner_data'

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

    def initialize
      super
      info "Creating Facebook #{self.class} subscription #{@path.brand.name}->#{@path.embed.name} with #{service_config}"

      begin
        subscribe_page
      rescue Koala::KoalaError => e
        info "Facebook subscription failed with #{e.message}"
      end

      publish preloaded_items, owner_data
    end

    private

    def owner_data
      OwnerData.new\
        @path.brand.id,
        @path.brand.name,
        @path.embed.id,
        @path.embed.name,
        @path.service.id,
        'facebook',
        'page_feed' # !!! probably irrelevant
    end

    def publish(items, owner_data)
      Actor[:event_publisher].publish items, owner_data
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
    end

    def unsubscribe_page
      client.graph_call "v2.2/#{page_id}/subscribed_apps", {access_token: page_token}, 'delete'
    end

    def preloaded_items
      Fetchers::Facebook::GetFeed.fetch client, page_id
    end

  end
end
