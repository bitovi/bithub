require 'digest/md5'
require 'redis'
require 'andand'

class RedisSet
  def initialize(initial_world = [])
    @redis = Redis.new(:url => ENV['REDIS_URL'])

    unless initial_world.empty?
      initial_world.each {|elem| add_many elem}
    end
  end

  def add_many(data_set)
    data_set
    .map{|e| add(e)}
    .reduce(true){|acc, e| acc && e}
  end

  def test(data_elem)
    @redis.sismember key(data_elem), value(data_elem)
  end

  def members(key)
    @redis.smembers key
  end

  def empty?(key)
    @redis.smembers(key).empty?
  end

  def add(data_elem)
    (r = @redis.sadd key(data_elem), value(data_elem)) == 0 ? false : r
  end
  
  def colon_separated(path)
    path.join ':'
  end
  
  alias_method :seen?, :test
  alias_method :seen, :members
end

