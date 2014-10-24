require 'digest/md5'

class Api::V3::EmbedEntitiesController < Api::V3::BaseController
  before_filter :authenticate!

  helper_method :custom_cache_key
  helper_method :list_cache_key

  def index
    @embed = current_brand.embeds.find_by_id(embed_id)
    @entities = @embed.entities
    render :index
  end

  def destroy
    Entity.find(params[:id]).destroy
    render :json => { error: t('api.entities.destroy.success') }
  end

  private
  def embed_id
    params.require(:embed_id)
  end

  def custom_cache_key(event)
    qs  = CGI.parse(request.query_string)
    key = [event.cache_key]
    if !qs.blank?
      event_params = qs.reject{|k, v| !['exclude', 'include'].include?(k)}
      key << fragment_cache_key(event_params.sort) unless event_params.blank?
    end
    key.join('/')
  end

  def list_cache_key(events)
    qs  = CGI.parse(request.query_string)
    key = [events.map{|ev| ev.cache_key}.join("|")]
    if !qs.blank?
      key.unshift(fragment_cache_key(qs.sort))
    end
    Digest::MD5.hexdigest(key.join(':'))
  end
end
