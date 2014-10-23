class Api::V3::BrandsController < Api::V2::BaseController
  before_filter :authenticate!
  load_and_authorize_resource

  def show
    if (@brand = current_brand)
      render :show
    else
      render json: msg_hash(@brand, 'update'), status: 406
    end
  end

  def update
    if (@brand = current_brand)
      @brand.update_attributes(processed_brand_params)
      render :show
    else
      render json: msg_hash(@brand, 'update'), status: 406
    end
  end

  private

  def processed_brand_params
    params[:brand] = {} unless params.andand[:brand]
    params[:brand][:keywords] = [] unless brand.andand[:keywords]
    params.require(:brand).permit(
      :name,
      :description,
      :tenant_name,
      keywords: []
    )
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
