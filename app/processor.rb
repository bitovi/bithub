require 'lib/hash'
require 'lib/string'
require 'lib/proc'

require 'app/processors/blog'
require 'app/processors/disqus'
require 'app/processors/forums'
require 'app/processors/github'
require 'app/processors/twitter'

class Processor

  class InvalidEventException < Exception; end
  class MissingTimestamp < Exception; end

  include TwitterSpecific
  include GithubSpecific
  include ForumsSpecific
  include BlogSpecific

  def initialize(feed)
    @feed = feed
    @config = {}
    yield @config if block_given?
  end

  def process(event_hash)
    partly_processed_hash = {
      hash_key: event_hash['hash_key'],
      source_data: event_hash,
      meta: { feed: @feed.to_s }
    }

    send(@feed.to_sym, event_hash, partly_processed_hash)
  end

  def cons_origin_tss_hash(date)
    if block_given?
      pd = yield
    else
      pd = parse_date(date)
    end
    { origin_ts: pd.iso8601, origin_date: to_date_str(pd) }
  end

  def sanitize_body(text)
    text ? Sanitize.clean(text, Sanitize::Config::RELAXED) : "";
  end

  def parse_date(date_str)
    date_str ? Time.parse(date_str).utc : (raise MissingTimestamp, "missing origin timestamps");
  end

  def to_date_str(date)
    date.strftime("%Y-%m-%d")
  end
end
