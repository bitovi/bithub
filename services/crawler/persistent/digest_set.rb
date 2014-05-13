require_relative 'redis_set'

class DigestSet < RedisSet

  def reject_old(events)
    new_events = events.reject { |e| seen? e }
    new_events.each {|e| add e}
    new_events
  end

  def key(event)
    colon_separated [prefix] + keys_path(event)
  end

  def value(event)
    event.fetch(:content_digest)
  end

  def prefix
    "digests"
  end
    
  def keys_path(event)
    [event.fetch(:meta).fetch(:brand_name),
     event.fetch(:meta).fetch(:feed_name),
     event.fetch(:meta).fetch(:type_name)]
  end
end
