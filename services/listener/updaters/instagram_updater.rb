require 'andand'
require 'instagram'
require 'listener/updater'
require_relative 'client_builder'

class InstagramUpdater
  def initialize(updater, cycle, tenant_name)
    @updater = updater
    @cycle = cycle
    @tenant_name = tenant_name
    @client_builder = ClientBuilder.new(tenant_name, 'instagram')
    @client = @client_builder.build
  end

  def update
    if new_update_due?
      perform
      lock
    else
      Celluloid.logger.info "InstagramUpdater nothing to do"
    end
  end

  def perform
    media_ids = query_media_ids_to_update
    lookup_media(media_ids).andand.each do |m|
      popularity = m.likes[:count]
      Entity.find_by_origin_id(m.id.to_s).update_attribute(:popularity, popularity)
    end
    Celluloid.logger.debug "INSTAGRAM : REQUESTS_LEFT : #{requests_left}"
  rescue ::Instagram::TooManyRequests => e
    Celluloid.logger.warn "INSTAGRAM : RATE LIMIT HIT"
    retry if @client_builder.has_more_creds? && (@client = @client_builder.next)
  end
  
  def query_media_ids_to_update
    query = Entity
      .feed('instagram')
      .type('media')
      .where(:thread_updated_ts => @updater.cycle_to_date_range(@cycle))
      .order("updated_at ASC")
      .limit(100)

    query.pluck(:origin_id)
  end
  
  def lookup_media(media_ids)
    res = media_ids.map do |mid| 
      begin
        @client.media_item(mid)
      rescue Instagram::BadRequest => e
        nil
      end
    end.compact
    Celluloid.logger.debug "Fetched '#{res.count}' media" if res 
    res
  end
  
  def lock_name
    "lock:popularity_updater:#{@cycle}:#{@tenant_name}:instagram:media"
  end
  
  def lock
    redis.setex(lock_name, @updater.cycle_to_lock_duration(@cycle), "LOCKED")
  end

  def new_update_due?
    redis.get(lock_name).nil?
  end
  
  def requests_left
    rate_limits[:x_ratelimit_limit].to_i
  end

  def rate_limits
    @client.utils_raw_response
  rescue Error::TooManyRequests => e
    Celluloid.logger.info "WWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW"
  end
  
  def redis
    @updater.redis
  end
end

