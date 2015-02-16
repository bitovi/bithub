require 'digest/md5'

class Api::V3::EmbedEntitiesController < Api::V3::BaseController
  include Api::EmbedScoped

  before_filter :authenticate_account!, except: [:index]

  helper_method :custom_cache_key
  helper_method :list_cache_key

  def index
    @visibility = current_account ? params[:view] : 'public'

    if (tn = (params[:tenant_name] || Apartment::Tenant.current))
      tn = nil unless Apartment.tenant_names.include?(tn)
      Apartment::Tenant.switch(tn) do
        scope = build_scope
        @entities = EntityDecorator.decorate_collection(scope.all, context: { embed: owner_embed })
        render :index
      end
    end
  end

  def show
    @entity = EntityDecorator.decorate(entity_from_relation, context: { embed: owner_embed })
    render :show
  end

  def approve
    @visibility = 'admin'
    if (@relation = embed_entity_relation).approve
      @entity = EntityDecorator.decorate(entity_from_relation, context: { embed: owner_embed })
      render :show
    else
      render text: "error", status: 406
    end
  end

  def block
    @visibility = 'admin'
    if (@relation = embed_entity_relation).block
      @entity = EntityDecorator.decorate(entity_from_relation, context: { embed: owner_embed })
      render :show
    else
      render text: "error", status: 406
    end
  end
  alias_method :disapprove, :block

  def pin
    @visibility = 'admin'
    if (@relation = embed_entity_relation).pin
      @entity = EntityDecorator.decorate(entity_from_relation, context: { embed: owner_embed })
      render :show
    else
      render text: "error", status: 406
    end
  end
  
  def unpin
    @visibility = 'admin'
    if (@relation = embed_entity_relation).unpin
      @entity = EntityDecorator.decorate(entity_from_relation, context: { embed: owner_embed })
      render :show
    else
      render text: "error", status: 406
    end
  end

  def destroy
    if (@relation = embed_entity_relation).destroy
      render :json => msg_hash(@relation, 'destroy', 'success')
    else
      render :json => msg_hash(@relation, 'destroy'), :status => 406
    end
  end

  private

  def build_scope
    scope = Entity\
      .select('entities.*, embed_entities.is_approved AS is_approved, embed_entities.is_pinned AS is_pinned')
      .joins(:embed_entities)\
      .where("embed_entities.embed_id" => embed_id)

    if public_visibility? || show_only_visible?
      if owner_embed.approving?
        scope = scope.where('embed_entities.is_approved IS NULL OR embed_entities.is_approved = TRUE')
      elsif owner_embed.blocking?
        scope = scope.where('embed_entities.is_approved = TRUE')
      end
    elsif show_only_blocked? 
      if owner_embed.approving?
        scope = scope.where('embed_entities.is_approved = FALSE')
      elsif owner_embed.blocking?
        scope = scope.where('embed_entities.is_approved IS NULL OR embed_entities.is_approved = FALSE')
      end
    elsif show_only_pinned?
      scope = scope.where('embed_entities.is_pinned = TRUE')
    end

    if public_visibility? 
      scope = scope.order('embed_entities.is_pinned DESC, entities.thread_updated_ts DESC')
      params.delete(:order)
    elsif params[:order] == 'preview'
      params[:order] = ['is_pinned:desc', 'thread_updated_ts:desc']
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
    
    scope
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

  def entity_from_relation
    Entity.joins(:embed_entities)\
      .select('entities.*, embed_entities.is_approved AS is_approved, embed_entities.is_pinned AS is_pinned')
      .where('embed_entities.embed_id' => embed_id)\
      .where('entities.id' => entity_id).first
  end

  def entity_id
    params[:entity_id] || params[:id]
  end

  def show_only_pinned?
    params[:show] == 'pinned'
  end

  def show_only_blocked?
    params[:show] == 'blocked'
  end

  def show_only_visible?
    params[:show] == 'visible'
  end

  def show_all?
    params[:show].nil? || params[:show] == 'all'
  end

  def admin_visibility?
    @visibility == 'admin'
  end

  def public_visibility?
    @visibility == 'public'
  end
end
