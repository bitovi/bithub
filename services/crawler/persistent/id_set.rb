require_relative 'redis_set'

class MeetupEventIdSet < RedisSet

  def key(event)
    meta  = event.fetch(:meta)
    brand = meta.fetch(:brand_name)
    feed  = meta.fetch(:feed_name)
    type  = meta.fetch(:type_name)

    "ids:#{brand}:#{feed}:#{type}"
  end

  def value(event)
    event.fetch(:source_data).fetch(:id)
  end

end
