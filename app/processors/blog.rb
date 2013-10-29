class BlogProcessor

  def initialize(config = {})
  end

  def process(original_hash, partly_processed_hash)
    partly_processed_hash
    .deep_merge({
      title: original_hash['title'],
      url: original_hash['link'],
      body: Sanitize.clean(original_hash['description'], Sanitize::Config::RELAXED),
    })
  end

  def origin_timestamps(original_hash)
    Time.strptime(datetime_str(original_hash), "%e %b %Y").utc
  end

  private

  def datetime_str(original_hash)
    (str = original_hash['published']) ? str : (raise Processor::MissingTimestamp, "missing origin timestamps");
  end
end
