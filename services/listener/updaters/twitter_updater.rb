require 'listener/updaters/base_updater'

class TwitterUpdater < BaseUpdater
  def initialize(updater, cycle, brand)
    @feed_name = 'twitter'; @type_name = 'tweet'
    super
  end

  def perform
    tweet_ids = query_tweet_ids_to_update
    lookup_tweets(tweet_ids).andand.each do |t|
      popularity = t.retweet_count + t.favorite_count
      Entity.find_by_origin_id(t.id.to_s).update_attribute(:popularity, popularity)
    end
    Celluloid.logger.info "#{log_sig} Done with update. #{requests_left} requests left."
  rescue ::Twitter::Error::TooManyRequests => e
    Celluloid.logger.warn "#{log_sig} Rate limit hit"
    retry if @client_builder.has_more_creds? && (@client = @client_builder.next)
  end

  def lookup_tweets(tweet_ids)
    @client.statuses(tweet_ids)
  end

  def query_tweet_ids_to_update
    query = Entity
      .feed('twitter')
      .type('tweet')
      .where(:thread_updated_ts => @updater.cycle_to_date_range(@cycle))
      .order("updated_at ASC")
      .limit(1000)

    query.pluck(:origin_id)
  end
  
  def requests_left
    rate_limits[:remaining]
  end

  def rate_limits
    resp = ::Twitter::REST::Request.new(
      @client, :get,
      '/1.1/application/rate_limit_status.json',
      {resources: 'statuses'}
    ).perform[:resources][:statuses][:"/statuses/lookup"]
    resp
  rescue ::Twitter::Error::TooManyRequests => e
    Celluloid.logger.error "#{log_sig} Rate limit hit while trying to determine rate limits!"
  end

  private
  def log_sig
    "[UPDATER][TWITTER]"
  end
end
