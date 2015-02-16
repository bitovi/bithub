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

    def boot
      super

      Celluloid.logger.info "Creating Facebook #{self.class} subscription #{@path.brand.name}->#{@path.embed.name} with #{service_config}"

      # begin
      #   subscribe_app
      #   subscribe_page
      # rescue Koala::KoalaError => e
      #   Celluloid.logger.info "Facebook subscription failed with #{e.message}"
      # end

      publish preload_feed, owner_data
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

    ### REST API

    def client
      @client ||= Koala::Facebook::API.new page_token #, app_secret
    end

    def preload_feed
      Fetchers::Facebook::GetFeed.fetch client, page_id
    end

    ### Realtime API

    def client_rt
      @client_rt ||= Koala::Facebook::RealtimeUpdates.new\
        app_id: ENV['FACEBOOK_CLIENT_ID'],
        secret: ENV['FACEBOOK_CLIENT_SECRET']
        # app_access_token: ''
    end

    def subscribe_page
      client.graph_call "v2.2/#{page_id}/subscribed_apps", {access_token: page_token}, 'post'
    end

    def unsubscribe_page
      client.graph_call "v2.2/#{page_id}/subscribed_apps", {access_token: page_token}, 'delete'
    end

    def subscribe_app
      client_rt.subscribe 'page', 'feed', callback_url, ENV['FACEBOOK_SUBSCRIPTIONS_VERIFY_TOKEN']
    end

    def unsubscribe_app(object_id=nil)
      client_rt.unsubscribe object_id
    end

    def callback_url(opts={})
      domain = opts[:domain] || ENV['CRAWLER_HTTP_DOMAIN']
      port   = opts[:port]   || ENV['CRAWLER_HTTP_PORT'] || 80
      path   = File.join ENV['CRAWLER_HTTP_PREFIX'], 'facebook', 'page', 'feed'

      "http://#{domain}:#{port}#{path}"
    end

  end
end
