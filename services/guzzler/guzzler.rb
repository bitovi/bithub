require 'uri'
require 'guzzler/redis_connection'

module Guzzler
  def self.logger
    Celluloid.logger
  end

  def self.redis(&block)
    raise ArgumentError, "requires a block" unless block
    redis_pool.with(&block)
  end

  def self.redis_pool
    @redis ||= Guzzler::RedisConnection.create
  end

  def self.options
    { concurrency: 5 }
  end

  def self.logger
    Celluloid.logger
  end

end
