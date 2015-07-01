require 'twitter'
require 'instagram'

class ClientBuilder
  def initialize(tenant_name, feed_name)
    @tenant_name = tenant_name
    @feed_name = feed_name
    @current_cred_idx = 0
  end

  def has_more_creds?
    (creds.length - 1) > @current_cred_idx
  end

  def current_cred
    creds[@current_cred_idx]
  end

  def build
    @client = if @feed_name == 'twitter'
      Twitter::REST::Client.new do |config|
        config.consumer_key = ENV.fetch('TWITTER_CLIENT_ID')
        config.consumer_secret = ENV.fetch('TWITTER_CLIENT_SECRET')
        config.access_token = current_cred[:access_token]
        config.access_token_secret = current_cred[:access_secret]
      end
    elsif @feed_name == 'instagram'
      Instagram.config do |config|
        config.client_id = ENV.fetch('INSTAGRAM_CLIENT_ID')
        config.client_secret = ENV.fetch('INSTAGRAM_CLIENT_SECRET')
      end
      Instagram.client(:access_token => current_cred[:access_token])
    end
  end

  def creds
    @creds ||= BrandIdentity.joins(:brand)
      .where(provider: @feed_name)
      .where('brands.tenant_name = ?', @tenant_name)
      .map { |bi| bi.facade.credentials }
  end

  def next
    @current_cred_idx +=1
    build
  end
end
