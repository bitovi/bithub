require 'digest/md5'
require 'connection_manager'
require 'andand'

class RedisSet
  def initialize(initial_world = [])
    @redis = ConnectionManager.instance.redis

    unless initial_world.empty?
      initial_world.each {|elem| add_many elem}
    end
  end

  def add_batch(key, members)
    @redis.sadd(key, members)
  end
  
  def add_many(data_set)
    data_set
    .map{|e| add(e)}
    .reduce(true){|acc, e| acc && e}
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
end
