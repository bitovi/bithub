require 'uri'
require 'guzzler/redis_connection'
require 'guzzler/commands'

require 'guzzler/service'
require 'guzzler/service_error'

require 'guzzler/transformers/event_digester'
require 'guzzler/transformers/event_rejector'
require 'guzzler/transformers/event_decorator'

module Guzzler

  def self.logger
    Celluloid.logger
  end

  def self.redis(&block)
    raise ArgumentError, "requires a block" unless block
    redis_pool.with(&block)
  end

  def self.redis=(arg)
    @redis = if arg.is_a?(ConnectionPool)
      arg
    else
      Guzzler::RedisConnection.create(arg)
    end
  end

  def self.redis_pool
    @redis ||= Guzzler::RedisConnection.create
  end

  def self.processing_chain
    @chain ||= Guzzler::Transformers::Chain.new do |m|
      m.add EventDigester
      m.add EventRejector
      m.add EventDecorator
    end
  end

  def self.options
    { }
  end

  def self.logger
    Celluloid.logger
  end

  def self.static_config
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
      },
      tumblr: {
        api_key: ENV.fetch('TUMBLR_CLIENT_ID'),
        api_secret: ENV.fetch('TUMBLR_CLIENT_SECRET')
      }
    }
  end
end
