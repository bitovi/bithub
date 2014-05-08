require 'digest/md5'
require 'redis'
require 'andand'

class DigestSet
  def initialize(initial_world = {})
    @redis = Redis.new(:url => ENV['REDIS_URL'])

    unless initial_world.empty?
      initial_world.each {|event| add_many event}
    end
  end

  def reject_old(events)
    new_events = events.reject do |e|
      if seen? e
        Celluloid.logger.debug "(#{digest(e)}) SEEN"
        true
      else
        Celluloid.logger.debug "(#{digest(e)}) ADDED"
        false
      end
    end
    new_events.each {|e| add e}
    new_events
  end

  def add_many(events)
    events.map {|e| add(e)}.reduce{|acc, x| acc && x}
  end

  def test(event)
    @redis.sismember key(event), digest(event)
  end

  def seen(event)
    @redis.smembers key(event)
  end

  def add(event)
    @redis.sadd key(event), digest(event)
  end

  def key(event)
    meta  = event.fetch(:meta)
    brand = meta.fetch(:brand_name)
    feed  = meta.fetch(:feed_name)
    type  = meta.fetch(:type_name)

    "digests:#{brand}:#{feed}:#{type}"
  end

  def digest(event)
    event.fetch(:content_digest)
  end

  alias_method :seen?, :test
end
