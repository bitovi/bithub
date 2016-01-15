require 'guzzler/redis_connection'

module Guzzler
  # Type can be either 'listening' or 'polling'

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

  # -------

  def self.service_config(service_key)
    service_key.gsub!('guzzler:', '')
    redis do |conn|
      str = conn.get(service_key)
      str
    end
  end

  def self.smembers(k)
    redis do |conn|
      conn.smembers(k)
    end
  end
  
  def self.sdiff(*ks)
    redis do |conn|
      conn.sdiff(ks)
    end
  end
  
  def self.sadd(k, item)
    redis do |conn|
      conn.sadd(k, item)
    end
  end
  
  def self.srem(k)
    redis do |conn|
      conn.srem(k)
    end
  end

  def self.lpush(k, item)
    redis do |conn|
      conn.lpush(k, item.to_json)
    end
  end

  def self.zadd(k, score, item)
    redis do |conn|
      conn.zadd(k, score, item.to_json)
    end
  end

  def self.rpop(k)
    redis do |conn|
      conn.rpop(k)
    end
  end

end
