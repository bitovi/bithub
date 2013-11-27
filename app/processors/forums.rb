require 'app/sanitizer'

class ForumsProcessor

  def initialize(config = {})
    @sanitizer = Sanitizer.new
  end

  def process(original_hash, partly_processed_hash, fsc = nil)
    fail_if_invalid(original_hash)

    partly_processed_hash.deep_merge!({
      title: original_hash['title'],
      body: sanitize(original_hash['description']),
      url: original_hash['link'],
      meta: {
        type: original_hash['category'].snake_case,
        origin_author_name: original_hash['dc:creator'],
      }
    })

    partly_processed_hash[:meta][:tags] = [] + fsc.andand[:term]
    partly_processed_hash
  end
  
  def origin_timestamps(original_hash)
    Time.parse(datetime_str(original_hash)).utc
  end

  def unique_attribute(original_hash)
    (original_hash[:link] || original_hash['link'])
  end
  
  def events_from_response(response)
    response['rss']['channel']['item']
  end

  private

  def fail_if_invalid(original_hash)
    fail Processor::InvalidEventException, "not a valid forum post" if not(valid_post?(original_hash))
  end
  
  def valid_post?(original_hash)
    has_title?(original_hash) && has_body?(original_hash) && has_url?(original_hash)
  end

  def has_title?(original_hash)
    !!original_hash['title']
  end

  def has_body?(original_hash)
    !!original_hash['description']
  end

  def has_url?(original_hash)
    !!original_hash['link']
  end

  def sanitize(txt)
    @sanitizer.sanitize(txt)
  end

  def datetime_str(original_hash)
    (str = original_hash['pubDate']) ? str : (raise Processor::MissingTimestamp, "missing origin timestamps");
  end

end
