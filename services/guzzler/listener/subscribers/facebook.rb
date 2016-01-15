require 'koala'
require 'guzzler/error'

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

module Guzzler::Listener::Subscribers
  class FacebookPage < BaseSubscriber

    ### Current hack
    # if there is no (page) access token in service use app token,
    # skip RT subscription and only preload data from the page

    def subscribe
      client.graph_call "v2.2/#{page_id}/subscribed_apps", {access_token: page_token}, 'post'
      @registry.subscribe 'facebook', 'page', page_id, @service
    rescue ::Koala::KoalaError => e
      raise Guzzler::SubscriptionError.new(e)
    end

    def unsubscribe
      client.graph_call "v2.2/#{page_id}/subscribed_apps", {access_token: page_token}, 'delete'
      @registry.unsubscribe 'facebook', 'page', page_id, @service
    rescue ::Koala::KoalaError => e
      raise Guzzler::SubscriptionError.new(e)
    end
    
    def preload_items
      Fetchers::Facebook::GetFeed.new(client, { object_id: page_id }).fetch
    end

    private

    def page_id
      @service.config.fetch(:id)
    end

    def page_token
      @service.config.fetch(:access_token)
    end

    def client
      @client ||= Koala::Facebook::API.new page_token #, app_secret
    end
  end
end
