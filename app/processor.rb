require 'lib/core_ext'

require 'app/processors/blog'
require 'app/processors/disqus'
require 'app/processors/forums'
require 'app/processors/github'
require 'app/processors/twitter'

class Processor
  attr_accessor :is_user_stream

  class InvalidEventException < Exception; end
  class MissingTimestamp < Exception; end

  def initialize(feed)
    @feed = feed
    config = yield Hash.new if block_given?
    @feed_processor = Object::const_get(feed.capitalize + 'Processor').new(config || {})
  end

  def process(event_hash)
    pph = {}
    .deep_merge(hash_key_source_data_and_feed(event_hash))
    .deep_merge(origin_timestamps_hash(event_hash))

    @feed_processor.process(event_hash, pph)
  end

  def hash_key_source_data_and_feed(event_hash)
    p event_hash
    return {
      hash_key: event_hash['hash_key'],
      source_data: event_hash,
      meta: { feed: @feed.to_s }
    }
  end

  def origin_timestamps_hash(event_hash)
    otss = @feed_processor.origin_timestamps(event_hash)
    return {
      origin_ts: otss.iso8601,
      origin_date: to_date_str(otss)
    }
  end

  def to_date_str(date)
    date.strftime("%Y-%m-%d")
  end

end
