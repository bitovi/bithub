require 'core_ext'
require 'connection_manager'

class LockManager
  include Celluloid

  def initialize
    @redis = ConnectionManager.instance.redis
  end

  attr_accessor :interval

  def lock(lock_info)
    if lock_info.ttl == :infinity
      @redis.set lock_info.name, "LOCKED"
    else
      @redis.setex lock_info.name, lock_info.ttl, "LOCKED"
    end
  end

  def unlock(lock_info)
    @redis.del lock_info.name
  end

  def locked?(lock_info)
    !@redis.get(lock_info.name).nil?
  end
end
