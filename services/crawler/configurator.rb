require 'httparty'

class Configurator
  include Celluloid
  include CoreHelpers

  attr_reader :all_brands

  def initialize(opts)
    @env = opts.fetch(:environment)
    reload unless ENV['TRAVIS']
    Celluloid.logger.debug "All brands: #{@all_brands}"
  end

  def static_config
    @static_config ||= read_env_config
  end

  def brand(brand_name)
    reload unless @all_brands
    all_brands.fetch(brand_name.to_sym)
  end
  alias_method :brand_config, :brand

  def feed(brand_name, feed_name)
    reload unless @all_brands
    all_brands.fetch(brand_name.to_sym).fetch(feed_name.to_sym)
  end
  alias_method :feed_config, :feed

  def reload
    @all_brands = symbolize_keys(remote_config)
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
