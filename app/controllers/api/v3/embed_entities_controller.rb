require 'digest/md5'

class Api::V3::EmbedEntitiesController < Api::V3::BaseController
  before_filter :authenticate!

  helper_method :custom_cache_key
  helper_method :list_cache_key

  def index
    embed = current_brand.embeds.find(embed_id)
    entities = embed.embed_entities.includes(:entity).order('entities.thread_updated_ts').all.map(&:entity)

    @entities = EntityDecorator.decorate_collection entities
    render :index
  end

  def approved
    embed = current_brand.embeds.find(embed_id)
    entities = embed.embed_entities.approved.map(&:entity)

    @entities = EntityDecorator.decorate_collection entities
    render :index
  end

  def waitlisted
    embed = current_brand.embeds.find(embed_id)
    entities = embed.embed_entities.waitlisted.map(&:entity)

    @entities = EntityDecorator.decorate_collection entities
    render :index
  end

  def show
    embed = current_brand.embeds.find(embed_id)
    entity = embed.embed_entities.find(entity_id)

    @entity = EntityDecorator.decorate entity
    render :show
  end

  def update
    @embed = current_brand.embeds.find(embed_id)
    render :show
  end

  def approve
    if embed_entity_relation.approve
      render json: embed_entity_relation
    else
      render text: "error", status: 406
    end
  end

  def disaprove
    if embed_entity_relation.disaprove
      render json: embed_entity_relation
    else
      render text: "error", status: 406
    end
  end

  def destroy
    if embed_entity_relation.destroy
      render text: "ok"
    else
      render text: "error", status: 406
    end
  end

  private

  def embed_entity_relation
    embed = current_brand.embeds.find(embed_id)
    embed.embed_entities.where(entity_id: entity_id, embed_id: embed_id).first
  end

  def entity_id
    params[:entity_id] || params[:id]
  end

  def embed_id
    params.require(:embed_id)
  end
end
