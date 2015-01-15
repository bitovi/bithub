require 'httparty'
require 'supervisors/support/brand_info'
require 'supervisors/support/embed_info'
require 'supervisors/support/service_info'

class Configurator
  include Celluloid
  include CoreHelpers

  def initialize(opts)
    @env = opts.fetch(:environment)
    @config = config unless ENV['TRAVIS']
    Celluloid.logger.debug @config.to_yaml
  end

  def static_config
    @static_config ||= read_env_config
  end

  def brand(bi)
    config.fetch(:brands).select{|b| b.fetch(:id) == bi.id}.first
  end
  alias_method :brand_config, :brand

  def embed(bi, ei)
    brand(bi).andand.fetch(:embeds).select{|e| e.fetch(:id) == ei.id}.first
  end
  alias_method :embed_config, :embed

  def service(bi, ei, si)
    embed(bi, ei).andand.fetch(:services).select{|s| s.fetch(:id) == si.id}.first
  end
  alias_method :service_config, :service

  def config
    @config = symbolize_keys(remote_config)
  end

  def remote_config
    if @env == 'test'
      JSON.parse(File.read('config/test_account.json'))
    else
      res = HTTParty.get url
      raise 'Web component not running' unless res.code == 200
      res
    end
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
