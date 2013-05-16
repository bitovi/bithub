class Api::UsersController < Api::ApiController
  respond_to :json

  def index
    muster_query = request.env['muster.query']
    scope = build_scope(muster_query, params)
    
    if !muster_query[:count].blank?
      render :json => { :count => scope.count(muster_query[:count]) }
    else
      scope = apply_score_calculation_to_scope(scope)
      scope = scope_applier.apply_order_to_scope(scope, muster_query)
      @users = UserDecorator.decorate_collection(scope.all)
      render :index
    end
  end

  def show
    @user = UserDecorator.decorate(User.find(params[:id]))
    render :show
  end

  def update
    filtered_params = params.select {|param| User.accessible_attributes.include?(param)}

    if params[:countryISO]
      country = Country.where({:iso => params[:countryISO]}).first
      filtered_params[:country] = country if country
    end

    if User.update(params[:id], filtered_params)
      render :status => 200, :json => {:id => params[:id]}
    else
      render :json => @event.errors.messages, :status => 500
    end
  end

  private # SCOPE BUILDING
  def build_scope(muster_query, params)
    scope = User.scoped
    scope = scope_applier.apply_muster_query_to_scope(scope, muster_query)
    scope = scope_applier.apply_regular_params_to_scope(scope, params)
  end
  
  def apply_score_calculation_to_scope(scope)
    scope = scope.select_with_score
  end

  def logic_analyzer
    QueryLogicAnalyzer.new(User)
  end

  def scope_applier
    ScopeApplier.new(QueryLogicAnalyzer.new(User)) 
  end
end
