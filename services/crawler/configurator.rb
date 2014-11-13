require 'httparty'

class Configurator
  include Celluloid
  include CoreHelpers

  attr_reader :config

  def initialize(opts)
    @env = opts.fetch(:environment)
    reload unless ENV['TRAVIS']
    Celluloid.logger.debug "All brands: #{@all_brands}"
  end

  def static_config
    @static_config ||= read_env_config
  end

  def brand(brand_name)
    reload unless @config
    config.fetch(:brands).select {|b| b[:name] == brand_name}.first
  end
  alias_method :brand_config, :brand

  def embed(brand_name, embed_id)
    reload unless @config
    brand(brand_name).fetch(:embeds).select {|e| e[:id] == embed_id}.first
  end
  alias_method :embed_config, :embed

  def service(brand_name, embed_id, feed_name)
    reload unless @config
    embed(brand_name, embed_id).fetch(:services).select {|s| s[:feed_name] == feed_name}.first
  end
  alias_method :service_config, :service

  def reload
    @config = symbolize_keys(remote_config)
  end

  def remote_config
    HTTParty.get url
  end

  private

  def read_env_config
    {
      twitter: {
        api_key: ENV.fetch('TWITTER_CONSUMER_KEY'),
        api_secret: ENV.fetch('TWITTER_CONSUMER_SECRET')
      },
      disqus: {
        api_key: ENV.fetch('DISQUS_KEY'),
        api_secret: ENV.fetch('DISQUS_SECRET')
      },
      meetup: {
        personal_key: ENV.fetch('MEETUP_PERSONAL_KEY'),
        api_key: ENV.fetch('MEETUP_KEY'),
        api_secret: ENV.fetch('MEETUP_SECRET')
      },
      stackexchange: {
        api_key: ENV.fetch('STACKEXCHANGE_CLIENT_KEY'),
        api_secret: ENV.fetch('STACKEXCHANGE_CLIENT_SECRET'),
        filter: ENV.fetch('STACKEXCHANGE_FILTER')
      }
    }
  end

  def url
    ENV['CRAWLER_CONFIG']
  end

end
