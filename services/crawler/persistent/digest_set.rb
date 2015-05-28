require_relative 'redis_set'

class DigestSet < RedisSet

  def reject_old(events)
    set_key = key(events.first)

    seen_digests = members(set_key)
    new_events = events.reject { |e| seen_digests.include? e[:content_digest] }
    add_batch(set_key, new_events.map {|e| e[:content_digest]}) unless new_events.empty?

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
    [
      'brand/' + event.fetch(:meta).fetch(:brand_id).to_s,
      'embed/' + event.fetch(:meta).fetch(:embed_id).to_s,
      'service/' + event.fetch(:meta).fetch(:service_id).to_s,
      event.fetch(:meta).fetch(:feed_name),
      event.fetch(:meta).fetch(:type_name)
    ]
  end
end
