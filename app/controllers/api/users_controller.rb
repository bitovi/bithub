class Api::UsersController < Api::ApiController
  respond_to :json

  def index
    muster_query = request.env['muster.query']
    scope = build_scope(muster_query, params)
    
    if !muster_query[:count].blank?
      render :json => { :count => scope.count(muster_query[:count]) }
    else
      scope = apply_score_calculation_to_scope(scope)
      scope = apply_order_to_scope(scope, muster_query)
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

  private
  def build_scope(muster_query, params)
    scope = User.scoped ; logic_analyzer = QueryLogicAnalyzer.new(User)
    scope = ScopeApplier.apply_muster_query_to_scope(scope, muster_query)
    scope = ScopeApplier.apply_regular_params_to_scope(logic_analyzer, scope, params)
    scope
  end
  
  def apply_score_calculation_to_scope(scope)
    scope = scope.select_with_score(true)
  end
  
  def apply_order_to_scope(scope, muster_query)
    if !muster_query[:order].blank?
      attribute, direction = muster_query[:order].first.split
      attribute = "total_score" if attribute == "score" # total_score => calculated field
      scope = scope.order("#{attribute} #{direction}")
    end
    scope
  end
end
