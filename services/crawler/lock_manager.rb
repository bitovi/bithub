require 'core_ext'

class LockManager
  include Celluloid

  def initialize
    @redis = Redis.new(:url => ENV['REDIS_URL'])
  end

  attr_accessor :interval

  def lock(lock_name, interval)
    @redis.setex lock_name, interval, "LOCKED"
  end

  def unlock(lock_name)
    @redis.del lock_name
  end

  def locked?(lock_name)
    not @redis.get(lock_name).nil?
  end
end
