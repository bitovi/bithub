class BlogProcessor

  def initialize(config = {})
  end

  def process(original_hash, partly_processed_hash)
    partly_processed_hash
    .deep_merge({
      title: event['title'],
      url: event['link'],
      body: Sanitize.clean(event['description'], Sanitize::Config::RELAXED),
    })
  end

  def origin_timestamps(orig_hash)
    Time.strptime(datetime_str(orig_hash), "%e %b %Y").utc
  end

  private

  def datetime_str
    (str = original_hash['published']) ? str : (raise MissingTimestamp, "missing origin timestamps");
  end
end
