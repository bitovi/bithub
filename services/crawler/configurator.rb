require 'httparty'
require 'supervisors/support/service_info'

class Configurator
  include Celluloid
  include CoreHelpers

  attr_reader :config

  def initialize(opts)
    @env = opts.fetch(:environment)
    reload unless ENV['TRAVIS']
    Celluloid.logger.info "Config: #{@config.to_yaml}"
  end

  def static_config
    @static_config ||= read_env_config
  end

  def brand(brand_name)
    reload unless @config
    config.fetch(:brands).select {|b| b[:name] == brand_name}.first
  end
  alias_method :brand_config, :brand

  def embed(brand_name, embed_name)
    reload unless @config
    brand(brand_name).fetch(:embeds).select {|e| e[:name] == embed_name}.first
  end
  alias_method :embed_config, :embed

  def service(brand_name, embed_name, service_feed, service_type)
    reload unless @config
    embed(brand_name, embed_name)\
      .fetch(:services)\
      .select do |s|
        s[:feed_name] == service_feed && s[:type_name] == service_type
      end.first
  end
  alias_method :service_config, :service

  def reload
    @config = symbolize_keys(remote_config)
  end

  def remote_config
    res = HTTParty.get url
    raise 'Web component not running' unless res.code == 200
    res
  end

  private

  def read_env_config
    {
      twitter: {
        api_key: ENV.fetch('TWITTER_CLIENT_ID'),
        api_secret: ENV.fetch('TWITTER_CLIENT_SECRET')
      },
      disqus: {
        api_key: ENV.fetch('DISQUS_CLIENT_ID'),
        api_secret: ENV.fetch('DISQUS_CLIENT_SECRET')
      },
      meetup: {
        personal_key: ENV.fetch('MEETUP_PERSONAL_KEY'),
        api_key: ENV.fetch('MEETUP_CLIENT_ID'),
        api_secret: ENV.fetch('MEETUP_CLIENT_SECRET')
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
