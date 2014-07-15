class Api::V2::UsersController < Api::V2::BaseController
  before_filter :authenticate!
  load_and_authorize_resource except: [:add_role, :remove_role]

  def index
    if params[:cached] == "true"
      @users = Leaderboard.where("? = ANY(user_brands)", current_brand)
      render :index_cached
    else
      muster_query = request.env['muster.query']
      scope = build_scope(muster_query, params)
      if !muster_query[:count].blank?
        render :json => { :count => scope.count(muster_query[:count]) }
      else
        scope = scope_applier.apply_order_to_scope
        @users = UserDecorator.decorate_collection(scope.result.all)
        render :index
      end
    end
  end

  def show
    @user = UserDecorator.decorate(User.find(params[:id]))
    render :show
  end

  def update
    u = User.find(params[:id])

    if u.update_attributes(user_params)
      u.calculate_avatar_url
      u.save

      @user = UserDecorator.decorate u
      render :show
    else
      render :json => msg_hash(u, 'update'), :status => 406
    end
  end

  def destroy
    user = User.find(params[:id])

    if user && user.destroy
      @user = UserDecorator.decorate(user)
      render :show
    else
      render :json => msg_hash(u, 'destroy'), :status => 406
    end
  end

  # def from_github
  #   res = user_apis.from_github(params[:user])
  #   render :json => res
  # end

  # def from_twitter
  #   res = user_apis.from_twitter(params[:user])
  #   render :json => res
  # end

  def add_role
    user = User.find(params[:id])
    authorize! :manage_roles_on_user, user

    if user && user.add_role(params[:role])
      @user = UserDecorator.decorate(user)
      render :show
    else
      render :json => msg_hash(u, 'role_management'), :status => 406
    end
  end

  def remove_role
    user = User.find(params[:id])
    authorize! :manage_roles_on_user, user

    if user && user.remove_role(params[:role])
      @user = UserDecorator.decorate(user)
      render :show
    else
      render :json => msg_hash(u, 'role_management'), :status => 406
    end
  end

  private # SCOPE BUILDING

  def build_scope(muster_query, params)
    scope = User
    scope = scope.only_not_null_names
    scope = scope_applier(scope).apply_muster_query_to_scope(muster_query)
    scope = scope_applier(scope).apply_regular_params_to_scope
  end

  def logic_analyzer
    @logic_analyzer ||= QueryLogic::Query.new(User, params)
  end

  def scope_applier(current_scope = nil)
    @scope_applier ||= ScopeApplier.new(current_scope || User, logic_analyzer)
  end

  def user_apis
    @user_apis ||= Accounts::ThirdPartyUserInformer.new
  end

  def user_params
    if params[:countryISO]
      country = Country.where({:iso => params[:countryISO]}).first
      params[:country] = country ? country : nil
    end

    params.require(:user).permit(:name, :email, :address, :address2, :city, :postal, :state, :country)
  end

end
