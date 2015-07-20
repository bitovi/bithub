require 'andand'
require 'listener/updater'
require 'listener/updaters/client_builder'

class BaseUpdater
  def initialize(updater, cycle, brand)
    @updater = updater; @cycle = cycle; @brand = brand
    @client_builder = ClientBuilder.new(brand, @feed_name)
    @client = @client_builder.build
  end
  attr_reader :client

  def update
    if new_update_due?
      Celluloid.logger.info "#{log_sig} Performing update..."
      perform
      lock
    end
  end

  def lock_name
    "lock:popularity_updater:#{@cycle}:#{@brand.tenant_name}:#{@feed_name}:#{@type_name}"
  end

  def lock
    redis.setex(lock_name, @updater.cycle_to_lock_duration(@cycle), "LOCKED")
  end

  def new_update_due?
    redis.get(lock_name).nil?
  end

  def redis
    @updater.redis
  end
end
