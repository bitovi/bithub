class Api::V3::BrandsController < Api::V3::BaseController
  before_filter :authenticate_account!

  def show
    authorize! :show, current_brand
    render :show
  end

  def create
    authorize! :create, built_brand

    if @brand.save
      render :show
    else
      render :json => msg_hash(@brand, 'create'), :status => 422
    end
  end

  def update
    authorize! :update, current_brand

    if @brand.update_attributes brand_params
      render :show
    else
      render json: msg_hash(@brand, 'update'), status: 422
    end
  end

  def destroy
    authorize! :destroy, a_brand
    
    if @brand.destroy
      render :json => msg_hash(@brand, 'destroy', 'success'), :status => 204
    else
      render :json => msg_hash(@brand, 'destroy'), :status => 422
    end
  end

  private

  def a_brand
    @brand = Brand.find(params[:id])
  end
  
  def built_brand
    @brand = Brand.new(brand_params)
  end

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
