require 'digest/md5'

class Api::V4::EmbedEntitiesController < Api::V3::EmbedEntitiesController
  include Api::EmbedScoped

  DECISIONS = ['approved', 'deleted', 'pending', 'starred']
  
  def index
    super do
      Apartment::Tenant.switch(@tenant_name) do
        scope = build_scope
        @entities = EntityDecorator.decorate_collection(scope.all, context: { embed: owner_embed })
        render 'api/v4/embed_entities/index'
      end
    end
  end

  def show
    if entity = entity_from_relation!
      authorize! :show, entity
      @entity = EntityDecorator.decorate(entity, context: { embed: owner_embed })
      render 'api/v4/embed_entities/show'
    end
  end

  def decide
    if @relation = embed_entity_relation!
      authorize! :decide, @relation
      if @relation.decide(decision)
        decorate_entity
        render 'api/v4/embed_entities/show'
      end
    end
  end

  private

  def build_scope
    select_sql_statement = <<-SQL
      entities.*,
      embed_entities.decision AS decision
    SQL

    scope = Entity\
      .select(select_sql_statement)
      .includes(:events)\
      .includes(:services)\
      .joins(:embed_entities)\
      .where("embed_entities.embed_id" => embed_id)


    scope = scope.by_service(service_id) if service_id
    scope = scope.image_only if image_only?
    scope = scope.where('embed_entities.decision' => decision) if decision

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
      params[:order] = ['thread_updated_ts:desc']
    end

    scope = scope.includes(:parent).no_children

    scope = scope_applier(scope)
      .apply_negated_attrs_to_scope
      .apply_muster_query_to_scope(muster_query)
      .apply_regular_params_to_scope
      .apply_tag_based_params_to_scope
      .apply_order_to_scope
      .result

    scope
  end
  

  def decision
    if params[:decision] && DECISIONS.include?(params[:decision])
      params[:decision]
    end
  end
end
