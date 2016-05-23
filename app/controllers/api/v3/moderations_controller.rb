require 'digest/md5'

class Api::V3::ModerationsController < Api::V3::ApiController
  include Api::HubScoped

  skip_filter :require_user!, only: [:index]

  helper_method :custom_cache_key
  helper_method :list_cache_key

  def index
    if user_signed_in? && !params[:tenant_name]
      @tenant_name = Apartment::Tenant.current
      @visibility = params[:view] || 'public'
    else
      @tenant_name = params[:tenant_name]
      @visibility = 'public'
    end

    if @tenant_name.blank? || !Apartment.tenant_names.include?(@tenant_name)
      show_406('Valid tenant name must be provided')
      return 
    end

    if block_given?
      yield
    else
      Apartment::Tenant.switch(@tenant_name) do
        scope = build_scope
        @bits = BitDecorator.decorate_collection(scope.all, context: { hub: owner_hub })
        render :index
      end
    end
  end

  def show
    if @relation = bit_from_relation!
      authorize! :show, @relation
      decorate_bit
      render :show
    end
  end

  def approve
    if @relation = moderation_relation!
      authorize! :approve, @relation
      if @relation.approve
        decorate_bit
        render :show
      end
    end
  end

  def block
    if @relation = moderation_relation!
      authorize! :block, @relation
      if @relation.block
        decorate_bit
        render :show
      end
    end
  end
  alias_method :disapprove, :block

  def pin
    if @relation = moderation_relation!
      authorize! :pin, @relation
      if @relation.pin
        decorate_bit
        render :show
      end
    end
  end

  def unpin
    if @relation = moderation_relation!
      authorize! :unpin, @relation
      if @relation.unpin
        decorate_bit
        render :show
      end
    end
  end

  def decide
    if @relation = moderation_relation!
      authorize! :decide, @relation
      if @relation.decide(decision)
        decorate_bit
        render :show
      end
    end
  end

  def destroy
    if @relation = moderation_relation!
      authorize! :destroy, @relation
      if @relation.destroy
        render :json => msg_hash(Moderation, 'destroy', 'success'), :status => 204
      end
    end
  end

  private

  def build_scope
    select_sql_statement = <<-SQL
      bits.*,
      moderations.is_approved_automatically AS is_approved_automatically,
      moderations.is_approved_manually AS is_approved_manually,
      moderations.is_pinned AS is_pinned,
      moderations.decision AS decision
    SQL

    scope = Bit\
      .select(select_sql_statement)
      .includes(:events)\
      .includes(:services)\
      .joins(:moderations)\
      .where("moderations.hub_id" => hub_id)

    scope = scope.by_service(service_id) if service_id
    scope = scope.image_only if image_only?

    if public_visibility? || show_only_visible?
      scope = owner_hub.approved_bits(scope)
    elsif show_only_blocked?
      scope = owner_hub.blocked_bits(scope)
    elsif show_only_pinned?
      scope = owner_hub.pinned_entitites(scope)
    end

    if public_visibility?
      scope = scope.order('moderations.is_pinned DESC, bits.thread_updated_ts DESC')
      params.delete(:order)
    elsif params[:order] == 'preview'
      params[:order] = ['is_pinned:desc', 'thread_updated_ts:desc']
    end

    scope = scope
      .where("bits.is_pending" => false)
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
    @query_logic ||= QueryLogic::Query.new(Bit, params)
  end

  def scope_applier(current_scope = nil)
    ScopeApplier.new((current_scope || Bit), query_logic)
  end

  def moderation_relation!
    owner_hub.moderations.where(bit_id: bit_id).first!
  end

  def bit_from_relation!
    select_sql = <<-SQL
      bits.*,
      moderations.is_approved_automatically AS is_approved_automatically,
      moderations.is_approved_manually AS is_approved_manually,
      moderations.is_pinned AS is_pinned
    SQL

    Bit.joins(:moderations)\
      .select(select_sql)
      .where('moderations.hub_id' => hub_id)\
      .where('bits.id' => bit_id)
      .first!
  end

  def decorate_bit
    @bit = BitDecorator.decorate(
      @relation.bit, context: { hub: owner_hub })
  end

  def bit_id
    params[:bit_id] || params[:id]
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

  def decision
    params[:decision] || 'pending'
  end
end
