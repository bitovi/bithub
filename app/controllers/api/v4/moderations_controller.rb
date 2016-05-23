require 'digest/md5'

class Api::V4::ModerationsController < Api::V3::ModerationsController
  include Api::HubScoped

  def index
    super do
      Apartment::Tenant.switch(@tenant_name) do
        scope = build_scope
        @count =  build_count_scope.count
        @bits = BitDecorator.decorate_collection(scope.all, context: { hub: owner_hub })
        render 'api/v4/moderations/index'
      end
    end
  end

  def show
    if bit = bit_from_relation!
      authorize! :show, bit
      @bit = BitDecorator.decorate(bit, context: { hub: owner_hub })
      render 'api/v4/moderations/show'
    end
  end

  def decide
    if @relation = moderation_relation!
      authorize! :decide, @relation
      if @relation.decide(decision)
        decorate_bit
        render 'api/v4/moderations/show'
      end
    end
  end

  def stats
    render :json => [{
      id: 'approved',
      count: owner_hub.moderations.where(:decision => 'approved').count
    }, {
      id: 'pending',
      count: owner_hub.moderations.where(:decision => 'pending').count
    }, {
      id: 'deleted',
      count: owner_hub.moderations.where(:decision => 'deleted').count
    }, {
      id: 'starred',
      count: owner_hub.moderations.where(:decision => 'starred').count
    }]
  end

  private

  def build_scope
    select_sql_statement = <<-SQL
      bits.*,
      moderations.decision AS decision
    SQL

    scope = Bit\
      .select(select_sql_statement)
      .includes(:events)\
      .includes(:services)\
      .includes(:parent)\
      .joins(:moderations)\
      .where("moderations.hub_id" => hub_id)
      .no_children

    scope = scope.by_service(service_id) if service_id
    scope = scope.image_only if image_only?
    scope = scope.where('moderations.decision' => decision) if decision

    if public_visibility?
      order_stmts = 'moderations.decision DESC, thread_updated_ts DESC'
      if params[:order] == 'timeline'
        order_stmts = 'thread_updated_ts DESC'
      end
      scope = scope.order(order_stmts)
      params.delete(:order)
    else
      order_by = ['moderations:desc', 'thread_updated_ts:desc']
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
    count_scope = Bit\
      .joins(:moderations)\
      .includes(:parent)\
      .where("moderations.hub_id" => hub_id)
      .no_children

    count_scope = count_scope.by_service(service_id) if service_id
    count_scope = count_scope.image_only if image_only?
    count_scope = count_scope.where('moderations.decision' => decision) if decision

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
    if params[:decision] && Moderation::DECISIONS.include?(params[:decision])
      translate_decision(params[:decision])
    else
      translate_decision('approved')
    end
  end

  def translate_decision(decision)
    if public_visibility?
      (decision == 'approved') ? %w(approved starred) : decision
    else
      decision
    end
  end
end
