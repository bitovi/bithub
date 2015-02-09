require 'digest/md5'

class Api::V3::EmbedEntitiesController < Api::V3::BaseController
  include Api::EmbedScoped

  before_filter :authenticate_account!, except: [:index]

  helper_method :custom_cache_key
  helper_method :list_cache_key

  def index
    if tenant_name = params['tenant_name']
      visibility = :admin

      # check if tenant_name exists
      tenant_name = nil unless Brand.find_by_tenant_name tenant_name

      Apartment::Tenant.switch tenant_name do
        scope = build_scope(visibility)
        @entities = EntityDecorator.decorate_collection(scope.all)
        render :index
      end
    else
      visibility = :public

      scope = build_scope(visibility)
      @entities = EntityDecorator.decorate_collection(scope.all)
      render :index
    end
  end

  def approved
    entities = owner_embed.embed_entities.approved.map(&:entity)

    @entities = EntityDecorator.decorate_collection entities
    render :index
  end

  def waitlisted
    entities = owner_embed.embed_entities.waitlisted.map(&:entity)

    @entities = EntityDecorator.decorate_collection entities
    render :index
  end

  def show
    entity = owner_embed.embed_entities.find(entity_id)

    @entity = EntityDecorator.decorate(entity)
    render :show
  end

  def update
    @embed = owner_embed
    render :show
  end

  def approve
    if (@relation = embed_entity_relation).approve(current_account)
      @entity = EntityDecorator.decorate(embed_entity_relation.entity)
      render :show_relation
    else
      render text: "error", status: 406
    end
  end

  def disapprove
    if (@relation = embed_entity_relation).disaprove(current_account)
      @entity = EntityDecorator.decorate(embed_entity_relation.entity)
      render :show_relation
    else
      render text: "error", status: 406
    end
  end

  def pin
    if (@relation = embed_entity_relation).pin
      @entity = EntityDecorator.decorate(embed_entity_relation.entity)
      render :show_relation
    else
      render text: "error", status: 406
    end
  end
  
  def unpin
    if (@relation = embed_entity_relation).unpin
      @entity = EntityDecorator.decorate(embed_entity_relation.entity)
      render :show_relation
    else
      render text: "error", status: 406
    end
  end

  def destroy
    if (@relation = embed_entity_relation).destroy
      render json: embed_entity_relation
    else
      render text: "error", status: 406
    end
  end

  private

  def build_scope(visibility)
    scope = Entity.joins(:embed_entities)\
      .where("embed_entities.embed_id" => embed_id)

    if visibility == :public
      if owner_embed.approving?
        scope = scope.where("embed_entities.is_approved <> false")
      elsif owner_embed.blocking?
        scope = scope.where("embed_entities.is_approved = true")
      end
    end

    scope = scope
      .where("entities.is_pending" => false)
      .includes(:parent)
      .no_children

    scope = scope_applier(scope)
    .apply_negated_attrs_to_scope
    .apply_muster_query_to_scope(muster_query)
    .apply_regular_params_to_scope
    .apply_tag_based_params_to_scope
    .apply_order_to_scope
    .result
  end

  def query_logic
    @query_logic ||= QueryLogic::Query.new(Entity, params)
  end

  def scope_applier(current_scope = nil)
    ScopeApplier.new((current_scope || Entity), query_logic)
  end

  def embed_entity_relation
    owner_embed.embed_entities.where(entity_id: entity_id, embed_id: embed_id).first
  end

  def entity_id
    params[:entity_id] || params[:id]
  end
end
