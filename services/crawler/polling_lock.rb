require 'core_ext'

class PollingLock

  def initialize(brand_name, fetcher_name, interval)
    @redis = Redis.new(:url => ENV['REDIS_URL'])
    @brand_name = brand_name.to_s.snake_case
    @fetcher_name = fetcher_name.to_s.snake_case.gsub('fetchers','')
    @interval = interval
  end

  attr_accessor :interval

  def lock
    @redis.setex lock_name, @interval, "LOCKED"
  end

  def unlock
    @redis.del lock_name
  end

  def locked?
    not @redis.get(lock_name).nil?
  end

  def lock_name
    "polling_lock:#{@brand_name}:#{fetcher_name}"
  end

  def fetcher_name
    @fetcher_name.split('/').reject{|x| x == ""}.join(':')
  end

end
