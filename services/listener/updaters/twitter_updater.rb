require 'andand'
require 'twitter'
require 'listener/updater'
require_relative 'client_builder'

class TwitterUpdater
  SET_NAMES = %i(whole_set processed_set)

  def initialize(updater, cycle, tenant_name)
    @updater = updater
    @cycle = cycle
    @tenant_name = tenant_name
    @client_builder = ClientBuilder.new(tenant_name, 'twitter')
    @client = @client_builder.build
  end
  attr_reader :client

  def update
    if new_update_due?
      perform
      lock
    else
      Celluloid.logger.info "TwitterUpdater nothing to do"
    end
  end

  def perform
    tweet_ids = query_tweet_ids_to_update
    lookup_tweets(tweet_ids).andand.each do |t|
      popularity = t.retweet_count + t.favorite_count
      Entity.find_by_origin_id(t.id.to_s).update_attribute(:popularity, popularity)
    end
    Celluloid.logger.debug "TWITTER : RATE_LIMITS : #{rate_limits}"
  rescue ::Twitter::Error::TooManyRequests => e
    Celluloid.logger.warn "TWITTER : RATE LIMIT HIT"
    retry if @client_builder.has_more_creds? && (@client = @client_builder.next)
    pause_update(tweet_ids)
  end

  def pause_update(data)
    Celluloid.logger.debug "Setting pause lock #{pause_lock_name} resets in #{limit_resets_in}"
    redis.multi do
      redis.sadd(paused_data_key, data)
      redis.setex(pause_lock_name, limit_resets_in, "LOCKED")
    end
  end

  def clear_pause
    SET_NAMES.each do |set_key|
      redis.del(pause_lock_name)
    end
  end

  def lookup_tweets(tweet_ids)
    res = @client.statuses(tweet_ids)
    Celluloid.logger.debug "Fetched '#{res.count}' tweets" if res 
    res
  end

  def fetch_paused_data
    Hash[SET_NAMES.map do |k_set|
      [set, redis.get(paused_data_key(k_set))]
    end]
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

  def lock_name
    "lock:popularity_updater:#{@cycle}:#{@tenant_name}:twitter:tweet"
  end

  def lock
    redis.setex(lock_name, @updater.cycle_to_lock_duration(@cycle), "LOCKED")
  end

  def new_update_due?
    redis.get(lock_name).nil?
  end

  def limit_resets_in
    Time.at(rate_limits[:reset]).to_i - Time.now.to_i
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
    Celluloid.logger.info "WWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW"
  end

  def redis
    @updater.redis
  end
end

# # POSTUPAK
# za sve brandove
#   dohvati sve njihove keyeve / identitete
#     kreni updejt
#       ako udaris rate limit za key
#         ako imas drugi
#           napravi klijenta s drugim keyom i nastavi
#         ako ne
#           pause-resume
# 
# # PAUSE - RESUME
# prodji tweetova koliko mozes (s danim keyeveima) dok ne udaris rate-limit,
# u redis zapamti koje si id-eve updejtao
# probaj nastavit u Time.at(rate_limit_resets_at + 1)
# ako je prioritetniji nivo pogodio rate limit
# probaj ponovo u Time.at(rate_limit_resets_at + 1) dok ti ne uspije
