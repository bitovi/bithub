require 'core_ext'
require_relative 'connection_manager'

class LockManager
  include Celluloid

  def initialize
    @redis = ConnectionManager.instance.redis
  end

  attr_accessor :interval

  def lock(lock_info)
    @redis.setex lock_info.name, lock_info.ttl, "LOCKED"
  end

  def unlock(lock_info)
    @redis.del lock_info.name
  end

  def locked?(lock_info)
    not @redis.get(lock_info.name).nil?
  end
end
