require_relative 'redis_set'

class IdSet < RedisSet

  def initialize(brand, feed, type)
    @path = [brand, feed, type]
    super([])
  end

  def key(data_elem = nil)
    colon_separated [prefix] + @path
  end

  def value(data_elem)
    data_elem
  end

  def members
    super(key)
  end

  def empty?
    super(key)
  end
  
  def prefix
    "ids"
  end 
end
