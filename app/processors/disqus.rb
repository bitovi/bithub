class DisqusProcessor
  
  def initialize(config = {})
  end

  def process(original_hash, partly_processed_hash)

    partly_processed_hash
    .deep_merge({
      title: original_hash['thread']['title'],
      body: original_hash['message'],
      url: original_hash['url'],
      meta: {
        feed: 'disqus',
        origin_author_name: original_hash['author']['name'],
      }
    })
  end

  def origin_timestamps(orig_hash)
    # Disqus provides date in format: "2013-02-14T22:47:29" !!! we append 'Z'
    Time.parse(datetime_str(orig_hash)+"Z").utc
  end

  private
  
  def datetime_str(original_hash)
    (str = original_hash['createdAt']) ? str : (raise Processor::MissingTimestamp, "missing origin timestamps");
  end

end
