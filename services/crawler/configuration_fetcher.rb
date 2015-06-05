require 'httparty'
require 'supervisors/node_types/node_types'

class ConfigurationFetcher
  include Celluloid
  include Celluloid::Logger
  include CoreHelpers
  
  def static_config
    @static_config ||= env_config
  end

  def config
    fetch_until_available(is_available)
    is_available.wait
  end

  def is_available
    @condition ||= Condition.new
  end

  private

  def fetch_until_available(c)
    val = fetch_and_parse
    after(0) { c.broadcast(val) }
  rescue => e
    error "[CONFIGURATION_FETCHER] Web unresponsive, trying again in #{Intervals::COMMAND_HANDLER_RETRY} seconds."
    after(Intervals::COMMAND_HANDLER_RETRY) { fetch_until_available(c) }
  end

  def fetch_and_parse
    resp = HTTParty.get url
    hash = JSON.parse resp.body
    val = symbolize_keys hash
    val
  end

  def env_config
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
    ENV['CRAWLER_CONFIG'] + '?secret=' + ENV['CRAWLER_SECRET_KEY']
  end
end
