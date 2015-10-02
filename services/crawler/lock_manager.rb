require 'core_ext'
require 'connection_manager'
require 'types/lock'

class LockManager
  include Celluloid
  include Celluloid::Logger

  def initialize(opts={})
    @redis = opts.fetch(:redis) { ConnectionManager.instance.redis }
    @booted = true
  end

  attr_accessor :interval

  def lock(lock)
    if lock.ttl == :infinity
      @redis.set lock.name, "LOCKED"
    else
      @redis.setex lock.name, lock.ttl, "LOCKED"
    end
  end

  def unlock(lock)
    @redis.del lock.name
  end

  def locked?(lock)
    !@redis.get(lock.name).nil?
  end

  def available?
    @booted
  end
end
