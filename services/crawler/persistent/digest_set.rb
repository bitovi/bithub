require_relative 'redis_set'

class DigestSet < RedisSet

  def reject_old(events)
    new_events = events.reject { |e| seen? e }
    new_events.each {|e| add e}
    new_events
  end

  def key(event)
    meta  = event.fetch(:meta)
    brand = meta.fetch(:brand_name)
    feed  = meta.fetch(:feed_name)
    type  = meta.fetch(:type_name)

    "digests:#{brand}:#{feed}:#{type}"
  end

  def value(event)
    event.fetch(:content_digest)
  end
end
