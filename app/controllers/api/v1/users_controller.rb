class Api::V1::UsersController < Api::V1::BaseController
  before_filter :authenticate_user!, except: [:index, :show]
  respond_to :json

  rescue_from ActiveRecord::RecordNotFound, with: :show_404
  rescue_from ActiveRecord::RecordInvalid, with: :show_406
  rescue_from CanCan::AccessDenied, with: :show_401

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
      params[:country] = country ? country : nil
    end

    u = User.find(params[:id])
    filtered_params = params.select {|param| User.accessible_attributes.include?(param)}

    if u.update_attributes(filtered_params)
      @user = UserDecorator.decorate(u)
      render :show
    else
      render :json => msg_hash(u, 'update'), :status => 406
    end
  end

  def from_github
    res = user_apis.from_github(params[:user])
    render :json => res
  end

  def from_twitter
    res = user_apis.from_twitter(params[:user])
    render :json => res
  end

  def add_role
    authorize! :manage_roles, User, :message => "No rights to manage user roles!"
    user = User.find(params[:id])
    if user && user.add_role(params[:role])
      @user = UserDecorator.decorate(user)
      render :show
    else
      render :json => msg_hash(u, 'role_management'), :status => 406
    end
  end

  def remove_role
    authorize! :manage_roles, User, :message => "No rights to manage user roles!"
    user = User.find(params[:id])
    if user && user.remove_role(params[:role])
      @user = UserDecorator.decorate(user)
      render :show
    else
      render :json => msg_hash(u, 'role_management'), :status => 406
    end
  end

  private # SCOPE BUILDING
  def build_scope(muster_query, params)
    scope = User.scoped
    scope = scope.only_not_null_names
    scope = scope_applier.apply_muster_query_to_scope(scope, muster_query)
    scope = scope_applier.apply_regular_params_to_scope(scope, params)
  end
  
  def logic_analyzer
    @logic_analyzer ||= QueryLogicAnalyzer.new(User)
  end

  def scope_applier
    @scope_applier ||= ScopeApplier.new(logic_analyzer) 
  end

  def user_apis
    @user_apis ||= Accounts::ThirdPartyUserInformer.new
  end
end
