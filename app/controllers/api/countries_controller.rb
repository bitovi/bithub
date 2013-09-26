class Api::CountriesController < ApplicationController
  load_and_authorize_resource
  respond_to :json

  rescue_from ActiveRecord::RecordNotFound, with: :show_404
  rescue_from ActiveRecord::RecordInvalid, with: :show_406

  def index
    scope = build_scope(request.env['muster.query'])
    scope = scope_applier.apply_order_to_scope(scope, params)
    @countries = scope.all
    render :index
  end
  
  def logic_analyzer
    @logic_analyzer ||= QueryLogicAnalyzer.new(Country)
  end

  def scope_applier
    @scope_applier ||= ScopeApplier.new(logic_analyzer) 
  end

  def build_scope(muster_query)
    scope = Country.scoped
    scope = scope_applier.apply_muster_query_to_scope(scope, muster_query)
  end

end
