class Api::V2::CountriesController < Api::V2::BaseController
  before_filter :authenticate!
  load_and_authorize_resource

  def index
    scope = build_scope(request.env['muster.query'], params)
    @countries = scope.all
    render :index
  end

  private

  def query_logic(params)
    @logic_analyzer ||= QueryLogic::Query.new(Country, params)
  end

  def scope_applier(params, current_scope = nil)
    @scope_applier ||= ScopeApplier.new(current_scope || Country, query_logic(params))
  end

  def build_scope(muster_query, params)
    scope = Country

    scope_applier(params, scope)
    .apply_order_to_scope
    .result
  end

end
