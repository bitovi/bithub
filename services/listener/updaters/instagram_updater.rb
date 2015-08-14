require 'listener/updaters/base_updater'

class InstagramUpdater < BaseUpdater
  def initialize(updater, cycle, brand)
    @feed_name = 'instagram'; @type_name = 'media'
    super
  end

  def perform
    media_ids = query_media_ids_to_update
    lookup_media(media_ids).andand.each do |m|
      popularity = m.likes[:count]
      Entity.find_by_origin_id(m.id.to_s).update_attribute(:popularity, popularity)
    end
    Celluloid.logger.info "#{log_sig} Done with update. #{requests_left} requests left."
  rescue Instagram::TooManyRequests => e
    Celluloid.logger.warn "#{log_sig} Rate limit hit"
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
    media_ids.map do |mid| 
      begin
        @client.media_item(mid)
      rescue Instagram::BadRequest => e
        nil
      end
    end.compact
  end
  
  def requests_left
    if rate_limits
      rate_limits[:x_ratelimit_limit].to_i
    else
      -1
    end
  end

  def rate_limits
    @client.utils_raw_response
  rescue Instagram::TooManyRequests => e
    Celluloid.logger.error "#{log_sig} Rate limit hit #{e}"
    nil
  rescue Instagram::BadRequest => e
    Celluloid.logger.error "#{log_sig} Bad request #{e}"
    nil
  end
  
  private
  def log_sig
    "[UPDATER][INSTAGRAM]"
  end
end

