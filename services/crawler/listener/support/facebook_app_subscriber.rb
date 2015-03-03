class FacebookAppSubscriber
  include Celluloid

  def client_rt
    @client_rt ||= Koala::Facebook::RealtimeUpdates.new\
      app_id: ENV['FACEBOOK_CLIENT_ID'],
      secret: ENV['FACEBOOK_CLIENT_SECRET']
    # app_access_token: ''
  end

  def subscribe
    client_rt.subscribe 'page', 'feed', callback_url, ENV['FACEBOOK_SUBSCRIPTIONS_VERIFY_TOKEN']
  end

  def unsubscribe(object_id=nil)
    client_rt.unsubscribe object_id
  end

  def callback_url(opts={})
    domain = opts[:domain] || ENV['CRAWLER_HTTP_DOMAIN']
    port   = opts[:port]   || ENV['CRAWLER_HTTP_PORT'] || 80
    path   = File.join ENV['CRAWLER_HTTP_PREFIX'], 'facebook', 'page', 'feed'

    "http://#{domain}:#{port}#{path}"
  end

end
