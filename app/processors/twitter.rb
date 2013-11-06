class TwitterProcessor

  def initialize(config)
    @user_stream_flag = config[:user_stream_flag]
  end

  def process(original_hash, partly_processed_hash)
    fail_if_invalid(original_hash)
    
    partly_processed_hash = partly_processed_hash
    .deep_merge({ meta: { feed: 'twitter' }})

    if is_user_stream? && is_follow_event?(original_hash)
      prepare_event_from_user_stream(original_hash, partly_processed_hash)
    elsif not(is_user_stream?) && is_status_event?(original_hash)
      prepare_event_from_public_stream(original_hash, partly_processed_hash)
    end
  end

  def origin_timestamps(original_hash)
    fail_if_invalid(original_hash)
    Time.parse(datetime_str(original_hash)).utc
  end
  
  def unique_attribute(original_hash)
    (original_hash[:id] || original_hash['id']).to_s
  end
  
  private
    
  def datetime_str(original_hash)
    (str = original_hash['created_at']) ? str : (raise Processor::MissingTimestamp, "missing origin timestamps");
  end

  def prepare_event_from_user_stream(event_hash, partly_processed_hash)
    partly_processed_hash.deep_merge({
      title: "followed @#{event_hash['target']['screen_name']}",
      hash_key: Digest::MD5.hexdigest(event_hash['source']['id_str'] + event_hash['target']['id_str'] + @feed.to_s),
      meta: {
        type: 'follow_event',
        origin_author_name: event_hash['source']['screen_name'],
        origin_author_id: event_hash['source']['id'],
      }
    })
  end

  def prepare_event_from_public_stream(event_hash, partly_processed_hash)
    fully_processed_hash = partly_processed_hash.deep_merge({
      title: event_hash['text'],
      hash_key: Digest::MD5.hexdigest(event_hash['id_str'] + @feed.to_s),
      url: "https://twitter.com/#{event_hash['user']['screen_name']}/status/#{event_hash['id_str']}",
      meta: {
        type: 'status_event',
        origin_author_name: event_hash['user']['screen_name'],
        origin_author_id: event_hash['user']['id'],
        origin_id: event_hash['id'],
        tweet_id: event_hash['id_str'],
      }
    })

    # add original tweet id -> used later for grouping retweets
    fully_processed_hash[:meta][:retweeted_id] = event_hash['retweeted_status']['id_str'] if event_hash['retweeted_status']
    fully_processed_hash
  end

  def fail_if_invalid(original_hash)
    fail Processor::InvalidEventException, "not a follow_event nor a status_event" if not(follow_or_status?(original_hash))
  end

  def follow_or_status?(event_hash)
    is_follow_event?(event_hash) || is_status_event?(event_hash)
  end
  
  def is_user_stream?
    @user_stream_flag
  end
  
  def is_follow_event?(event_hash)
    (event_hash['event'].andand == 'follow') && has_timestamp?(event_hash) && event_hash['target']['screen_name']
  end

  def is_status_event?(event_hash)
    event_hash['text'] && has_timestamp?(event_hash) && event_hash['user']['screen_name']
  end

  def has_timestamp?(event_hash)
    !!event_hash['created_at']
  end

end
