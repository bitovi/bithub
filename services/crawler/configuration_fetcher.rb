require 'httparty'
require 'supervisors/support/brand_info'
require 'supervisors/support/embed_info'
require 'supervisors/support/service_info'

class ConfigurationFetcher
  include Celluloid
  include CoreHelpers

  def static_config
    @static_config ||= env_config
  end

  def brand(bi)
    config.fetch(:brands).select{|b| b.fetch(:id) == bi.id}.first
  end
  alias_method :brand_config, :brand

  def embed(bi, ei)
    brand(bi).fetch(:embeds).select{|e| e.fetch(:id) == ei.id}.first
  end
  alias_method :embed_config, :embed

  def service(bi, ei, si)
    embed(bi, ei).fetch(:services).select{|s| s.fetch(:id) == si.id}.first
  end
  alias_method :service_config, :service

  def config
    c = Condition.new
    fetch_until_ok(c)
    c.wait
  end

  def fetch_until_ok(c)
    val = actually_fetch
    after(0) { c.broadcast(val) }
  rescue => e
    Celluloid.logger.error "Web unresponsive, trying again in 3 seconds"
    after(3) { fetch_until_ok(c) }
  end

  def actually_fetch
    resp = HTTParty.get url
    hash = JSON.parse resp.body
    val = symbolize_keys hash
    val
  end

  def traverse(feed_name, type_name, attr_name, attr_value)
    acc = []

    config.fetch(:brands).each do |b|
      b.fetch(:embeds).each do |e|
        e.fetch(:services).each do |s|
          if s[:feed_name] == feed_name && s[:type_name] == type_name && s[:config][attr_name.to_sym] == attr_value
            acc.push({
              brand_id: b[:id],
              brand_name: b[:name],
              embed_id: e[:id],
              embed_name: e[:name],
              service: s
            })
          end
        end
      end
    end

    acc
  end

  private

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
