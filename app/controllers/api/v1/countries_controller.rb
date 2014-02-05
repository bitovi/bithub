class Api::V1::CountriesController < Api::V1::BaseController
  load_and_authorize_resource
  respond_to :json

  rescue_from ActiveRecord::RecordNotFound, with: :show_404
  rescue_from ActiveRecord::RecordInvalid, with: :show_406

  def index
    scope = build_scope(request.env['muster.query'], params)
    @countries = scope.all
    render :index
  end

  def query_logic(params)
    @logic_analyzer ||= QueryLogic::Query.new(Country, params)
  end

  def scope_applier(params, current_scope = nil)
    @scope_applier ||= ScopeApplier.new(current_scope || Country.scoped, query_logic(params))
  end

  def build_scope(muster_query, params)
    scope = Country.scoped

    scope_applier(params, scope)
    .apply_order_to_scope
    .result
  end

end
