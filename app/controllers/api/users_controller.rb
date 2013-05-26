class Api::UsersController < Api::ApiController
  respond_to :json

  def index
    if params[:cached] == "true"
      @users = Leaderboard.all
      render :index_cached
    else
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
  end

  def show
    @user = UserDecorator.decorate(User.find(params[:id]))
    render :show
  end

  def update
    if params[:countryISO]
      country = Country.where({:iso => params[:countryISO]}).first
      params[:country] = country if country
    end

    u = User.find(params[:id])
    if u.update_attributes(params[:user])
      @user = UserDecorator.decorate(u)
      render :show
    else
      render :json => @event.errors.messages, :status => 406
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
    @logic_analyzer ||= QueryLogicAnalyzer.new(User)
  end

  def scope_applier
    @scope_applier ||= ScopeApplier.new(logic_analyzer) 
  end
end
