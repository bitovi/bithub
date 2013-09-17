module Grouping::TwitterSpecific

  def group_twitter    
    if tweet?
      if retweet?
        group_retweet
      else
        group_tweet
      end
    end
    self
  end

  def group_tweet
    if rts = my_retweets
      self.children += (rts + rts.collect{|rt| rt.children}.flatten).uniq
    end
    self
  end

  def group_retweet
    if ot = original_tweet
      self.parent = ot
    elsif frrt = first_related_retweet
      self.parent = frrt
    end
    self
  end

  def tweet?
    tag_list.include?('twitter') and tag_list.include?('status_event')
  end

  def retweet?
    !!props[:retweeted_id]
  end

  def my_retweets
    Event.tweets_by_retweeted_id(props[:tweet_id]).all
  end
  
  def original_tweet
    Event.tweets_by_tweet_id(props[:retweeted_id]).first
  end

  def first_related_retweet
    Event.tweets_by_retweeted_id(props[:retweeted_id]).order('origin_ts ASC').first
  end

end
