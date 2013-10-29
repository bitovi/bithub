require 'app/sanitizer'

class ForumsProcessor

  def initialize(sanitizer)
    @sanitizer = Sanitizer.new
  end

  def process(original_hash, partly_processed_hash)
    partly_processed_hash
    .deep_merge({
      title: original_hash['title'],
      body: sanitize(original_hash['description']),
      url: original_hash['link'],
      meta: {
        type: original_hash['category'].snake_case,
        origin_author_name: original_hash['dc:creator'],
        category: original_hash['filter_term'],
      }
    })
  end
  
  def origin_timestamps(orig_hash)
    Time.parse(datetime_str(orig_hash)).utc
  end

  private
  
  def sanitize(txt)
    @sanitizer.sanitize(txt)
  end

  def datetime_str(original_hash)
    (str = original_hash['pubDate']) ? str : (raise MissingTimestamp, "missing origin timestamps");
  end

end
