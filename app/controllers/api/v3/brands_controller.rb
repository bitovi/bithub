class Api::V3::BrandsController < Api::V3::BaseController
  before_filter :authenticate_account!
  load_and_authorize_resource

  def show
    if @brand = current_brand
      render :show
    else
      render json: msg_hash(@brand, 'show'), status: 404
    end
  end

  def create
    @brand = Brand.new brand_params
    if @brand.save
      render :show
    else
      render :json => msg_hash(@brand, 'create'), :status => 406
    end
  end

  def update
    if @brand = current_brand
      @brand.update_attributes brand_params
      render :show
    else
      render json: msg_hash(@brand, 'update'), status: 406
    end
  end

  def destroy
    @brand = Brand.find(params[:id])
    if @brand.destroy
      render :json => msg_hash(@brand, 'destroy', 'success'), :status => 200
    else
      render :json => msg_hash(@brand, 'destroy'), :status => 406
    end
  end

  private

  def brand_params
    params.require(:brand).permit(:name, :tenant_name)
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
