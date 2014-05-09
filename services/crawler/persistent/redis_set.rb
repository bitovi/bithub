require 'digest/md5'
require 'redis'
require 'andand'

class RedisSet
  def initialize(initial_world = {})
    @redis = Redis.new(:url => ENV['REDIS_URL'])

    unless initial_world.empty?
      initial_world.each {|event| add_many event}
    end
  end

  def add_many(events)
    events.map {|e| add(e)}.reduce{|acc, x| acc && x}
  end

  def test(event)
    @redis.sismember key(event), value(event)
  end

  def members(key)
    @redis.smembers key
  end

  def add(event)
    @redis.sadd key(event), value(event)
  end
  
  alias_method :seen?, :test
  alias_method :seen, :members
end

