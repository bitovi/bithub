require 'digest/md5'
require 'redis'
require 'andand'

class DigestSet
  def initialize(initial_world = {})
    @redis = Redis.new(:url => ENV['REDIS_URL'])
    unless initial_world.empty?
      initial_world.each {|brand, digests| add_many brand, digests}
    end
  end

  def reject_old(events, brand)
    new_events = events.reject {|e| seen? brand, e.fetch(:content_digest) }
    new_events.each {|e| add brand, e.fetch(:content_digest) }
    new_events
  end

  def add_many(brand, digests)
    digests.map{|d| add(brand, d)}.reduce{|acc, x| acc && x}
  end

  def test(brand, digest)
    @redis.sismember("digests:#{brand}", digest)
  end

  def seen(brand)
    @redis.smembers("digests:#{brand}")
  end

  def add(brand, digest)
    @redis.sadd("digests:#{brand}", digest)
  end

  alias_method :seen?, :test
end
