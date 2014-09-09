class Api::V2::BrandsController < Api::V2::BaseController
  before_filter :authenticate!
  load_and_authorize_resource

  def index
    @brands = Brand.all
    @brands_count = build_scope_for_counting.count
    render :index
  end

  def show
    if (@brand = current_account.brand)
      render :show
    else
      render :json => msg_hash(@brand, 'update'), :status => 406
    end
  end

  def update
    if (@brand = current_account.brand)
      @brand.update_attributes(brand_params)
      render :show
    else
      render :json => msg_hash(@brand, 'update'), :status => 406
    end
  end

  private

  def brand_params
    unless brand = params.andand[:brand]
      params[:brand] = {}
    end
    unless keywords = brand.andand[:keywords]
      params[:brand][:keywords] = []
    end

    params.require(:brand).permit(:description, :name, :tenant_name, :keywords => [])
  end

  def logic_analyzer
    @logic_analyzer ||= QueryLogic::Query.new(Brand, params)
  end

  def scope_applier(current_scope = nil)
    @scope_applier ||= ScopeApplier.new(current_scope || Brand, logic_analyzer)
  end

  def build_scope_for_counting
    scope_applier(Brand)\
      .apply_muster_query_to_scope(muster_query, skip_limits: true)\
      .apply_negated_attrs_to_scope\
      .apply_existence_attrs_to_scope\
      .apply_regular_params_to_scope\
      .result.offset(0).limit(1_000_000_000)
  end

end
