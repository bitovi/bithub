require 'digest/md5'

class Api::V4::EmbedEntitiesController < Api::V3::EmbedEntitiesController
  include Api::EmbedScoped

  def index
    super do
      Apartment::Tenant.switch(@tenant_name) do
        scope = build_scope
        @count =  build_count_scope.count
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

  def stats
    render :json => [{
      id: 'approved',
      count: owner_embed.embed_entities.where(:decision => 'approved').count
    }, {
      id: 'pending',
      count: owner_embed.embed_entities.where(:decision => 'pending').count
    }, {
      id: 'deleted',
      count: owner_embed.embed_entities.where(:decision => 'deleted').count
    }, {
      id: 'starred',
      count: owner_embed.embed_entities.where(:decision => 'starred').count
    }]
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
      .includes(:parent)\
      .joins(:embed_entities)\
      .where("embed_entities.embed_id" => embed_id)
      .no_children

    scope = scope.by_service(service_id) if service_id
    scope = scope.image_only if image_only?
    scope = scope.where('embed_entities.decision' => decision) if decision

    if public_visibility?
      order_stmts = 'embed_entities.decision DESC, thread_updated_ts DESC'
      if params[:order] == 'timeline'
        order_stmts = 'thread_updated_ts DESC'
      end
      scope = scope.order(order_stmts)
      params.delete(:order)
    else
      order_by = ['embed_entities:desc', 'thread_updated_ts:desc']
      if params[:order] == 'timeline'
        order_by = ['thread_updated_ts:desc']
      end
      params[:order] = order_by
    end

    scope = scope_applier(scope)
      .apply_negated_attrs_to_scope
      .apply_muster_query_to_scope(muster_query)
      .apply_regular_params_to_scope
      .apply_tag_based_params_to_scope
      .apply_order_to_scope
      .result

    scope
  end

  def build_count_scope
    count_scope = Entity\
      .joins(:embed_entities)\
      .includes(:parent)\
      .where("embed_entities.embed_id" => embed_id)
      .no_children

    count_scope = count_scope.by_service(service_id) if service_id
    count_scope = count_scope.image_only if image_only?
    count_scope = count_scope.where('embed_entities.decision' => decision) if decision

    count_scope = scope_applier(count_scope)
      .apply_negated_attrs_to_scope
      .apply_muster_query_to_scope(muster_query, skip_limits: true)
      .apply_regular_params_to_scope
      .apply_tag_based_params_to_scope
      .apply_order_to_scope
      .result

    count_scope
  end

  def decision
    if params[:decision] && EmbedEntity::DECISIONS.include?(params[:decision])
      params[:decision]
    else
      'approved'
    end
  end
end
