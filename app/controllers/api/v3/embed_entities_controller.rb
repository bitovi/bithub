require 'digest/md5'

class Api::V3::EmbedEntitiesController < Api::V3::BaseController
  include Api::EmbedScoped

  before_filter :authenticate_account!, except: [:index]

  helper_method :custom_cache_key
  helper_method :list_cache_key

  def index
    @visibility = current_account ? (params[:view] || 'public') : 'public'

    if (tn = (params[:tenant_name] || Apartment::Tenant.current))
      tn = nil unless Apartment.tenant_names.include?(tn)
      Apartment::Tenant.switch(tn) do
        scope = build_scope
        @entities = EntityDecorator.decorate_collection(
          scope.all, context: { embed: owner_embed })
        render :index
      end
    end
  end

  def show
    if @relation = entity_from_relation!
      authorize! :show, @relation
      decorate_entity
      render :show
    end
  end

  def approve
    if @relation = embed_entity_relation!
      authorize! :approve, @relation
      if @relation.approve
        decorate_entity
        render :show
      end
    end
  end

  def block
    if @relation = embed_entity_relation!
      authorize! :block, @relation
      if @relation.block
        decorate_entity
        render :show
      end
    end
  end
  alias_method :disapprove, :block

  def pin
    if @relation = embed_entity_relation!
      authorize! :pin, @relation
      if @relation.pin
        decorate_entity
        render :show
      end
    end
  end

  def unpin
    if @relation = embed_entity_relation!
      authorize! :unpin, @relation
      if @relation.unpin
        decorate_entity
        render :show
      end
    end
  end

  def destroy
    if @relation = embed_entity_relation!
      authorize! :destroy, @relation
      if @relation.destroy
        render :json => msg_hash(EmbedEntity, 'destroy', 'success'), :status => 204
      end
    end
  end

  private

  def build_scope
    select_sql_statement = <<-SQL
      entities.*,
      embed_entities.is_approved_automatically AS is_approved_automatically,
      embed_entities.is_approved_manually AS is_approved_manually,
      embed_entities.is_pinned AS is_pinned
    SQL

    scope = Entity\
      .select(select_sql_statement)
      .joins(:embed_entities)\
      .where("embed_entities.embed_id" => embed_id)

    scope = scope.by_service(service_id) if service_id
    scope = scope.image_only if image_only?

    if public_visibility? || show_only_visible?
      scope = owner_embed.approved_entities(scope)
    elsif show_only_blocked?
      scope = owner_embed.blocked_entities(scope)
    elsif show_only_pinned?
      scope = owner_embed.pinned_entitites(scope)
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

  def embed_entity_relation!
    owner_embed.embed_entities.where(entity_id: entity_id).first!
  end

  def entity_from_relation!
    select_sql = <<-SQL
      entities.*,
      embed_entities.is_approved_automatically AS is_approved_automatically,
      embed_entities.is_approved_manually AS is_approved_manually,
      embed_entities.is_pinned AS is_pinned
    SQL

    Entity.joins(:embed_entities)\
      .select(select_sql)
      .where('embed_entities.embed_id' => embed_id)\
      .where('entities.id' => entity_id)
      .first!
  end

  def decorate_entity
    @entity = EntityDecorator.decorate(
      @relation.entity, context: { embed: owner_embed })
  end

  def entity_id
    params[:entity_id] || params[:id]
  end

  def service_id
    params[:service_id]
  end

  def image_only?
    params[:image_only] == 'true' || params[:image_only] == true 
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
