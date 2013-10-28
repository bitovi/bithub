module TwitterSpecific

  def twitter(original_hash, partly_processed_hash)
    fail Processor::InvalidEventException, "event isn't a follow_event nor a status_event" if not(follow_or_status?(original_hash))

    partly_processed_hash = partly_processed_hash
    .deep_merge(cons_origin_tss_hash(original_hash['created_at']))
    .deep_merge({ meta: { feed: 'twitter' }})

    if is_user_stream? && is_follow_event?(original_hash)
      prepare_event_from_user_stream(original_hash, partly_processed_hash)
    elsif not(is_user_stream?) && is_status_event?(original_hash)
      prepare_event_from_public_stream(original_hash, partly_processed_hash)
    end
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
  
  def is_user_stream?
    @user_stream_flag || false
  end
  
  def is_follow_event?(event_hash)
    event_hash['event'] && (event_hash['event'] == 'follow') && event_hash['target']['screen_name'] && event_hash['created_at']
  end

  def is_status_event?(event_hash)
    event_hash['text'] && event_hash['user']['screen_name'] && event_hash['created_at'] 
  end

  def follow_or_status?(event_hash)
    is_follow_event?(event_hash) || is_status_event?(event_hash)
  end
end
