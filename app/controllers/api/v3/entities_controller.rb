require 'digest/md5'

class Api::V3::EntitiesController < Api::V3::BaseController
  before_filter :authenticate!
  load_and_authorize_resource

  def index
    embed_entities.all.map(&:entity)
    render :index
  end

  def approved
    @entities = embed_entities.approved.map(&:entity)
    render :index
  end

  def waitlisted
    @entities = embed_entities.waitlisted.map(&:entity)
    render :index
  end

  def show
    embed = current_brand.embeds.find(params[:embed_id])
    @entity = embed.entities.find(params[:id])
    render :show
  end

  def disapprove
    ee_relation = embed_entity(params[:embed_id], params[:id])
    ee_relation.disapprove
    render :json => { error: t('api.entities.disaprove.success') }
  end

  def destroy
    ee_relation = embed_entity(params[:embed_id], params[:id])
    ee_relation.disconnect
    render :json => { error: t('api.entities.destroy.success') }
  end

  private # SCOPE BUILDING

  def embed_entities
    current_brand.embeds.find(params[:embed_id]).embed_entities
  end

  def embed_entity(embed_id, entity_id)
    embed = current_brand.embeds.find(embed_id)
    embed.embed_entities.where(
      embed_id: embed_id,
      entity_id: entity_id,
    ).first
  end

  def set_params
    params[:clientTz] = request.headers['clientTz'] unless params[:clientTz]
    params[:order] = "thread_updated_ts:asc"  if params[:order] == "thread_updated_at:asc"
    params[:order] = "thread_updated_ts:desc" if params[:order] == "thread_updated_at:desc"
  end
end
