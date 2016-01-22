module Guzzler::Listener::Subscribers

  class FacebookAppSubscriber
    def initialize(condvar)
      @condvar = condvar
    end

    def subscribe
      @condvar.wait
      realtime_client.subscribe 'page', 'feed', callback_url, verify_token
    end

    def unsubscribe(object_id=nil)
      realtime_client.unsubscribe object_id
    end

    private

    def callback_url
      url = 'https://'
      url += domain
      url += path
      url
    end

    def domain
      if ENV['ENV'] == 'development'
        ENV.fetch('TUNNEL_CRAWLER_HTTP_DOMAIN')
      else
        ENV.fetch('CRAWLER_HTTP_DOMAIN')
      end
    end

    def path
      ENV.fetch('CRAWLER_HTTP_PREFIX') + '/facebook/page/feed'
    end

    def realtime_client
      return @realtime_client if @realtime_client
      @realtime_client = Koala::Facebook::RealtimeUpdates.new(client_opts.merge({:use_ssl => true}))
    end

    def client_opts
      { app_id: ENV.fetch('FACEBOOK_CLIENT_ID'), secret: ENV.fetch('FACEBOOK_CLIENT_SECRET') }
    end

    def verify_token
      ENV.fetch('FACEBOOK_SUBSCRIPTIONS_VERIFY_TOKEN')
    end
  end
end
