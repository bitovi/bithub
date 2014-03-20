class Api::V2::RewardsController < Api::V2::BaseController
  before_filter :authenticate_user!, except: [:index, :show]
  respond_to :json

  rescue_from ActiveRecord::RecordNotFound, with: :show_404
  rescue_from ActiveRecord::RecordInvalid, with: :show_406
  rescue_from CanCan::AccessDenied, with: :show_401

  def index
    scope = build_scope(request.env['muster.query'], params)
    @rewards = scope.all
    render :index
  end

  def show
    @reward = Reward.find(params[:id])
    render :show
  end

  def create
    authorize! :manage, Reward, :message => "No rights to manage rewards."
    @reward = Reward.new(params[:reward])
    if @reward.save
      render :show
    else
      render :json => msg_hash(@reward, 'create'), :status => 406
    end
  end

  def update
    authorize! :manage, Reward, :message => "No rights to manage rewards."
    @reward = Reward.find(params[:id])
    if @reward.update_attributes(params[:reward])
      render :show
    else
      render :json => msg_hash(@reward, 'update'), :status => 406
    end
  end

  def destroy
    authorize! :manage, Reward, :message => "No rights to manage rewards."
    @reward = Reward.find(params[:id])
    if @reward.destroy
      render :json => msg_hash(@reward, 'destroy', 'success')
    else
      render :json => msg_hash(@reward, 'destroy'), :status => 406
    end
  end

  # SCOPE BUILDING
  # --------------

  def query_logic(params)
    @logic_analyzer ||= QueryLogic::Query.new(Reward, params)
  end

  def scope_applier(params, current_scope = nil)
    @scope_applier ||= ScopeApplier.new(current_scope || Reward.scoped, query_logic(params))
  end

  def build_scope(muster_query, params)
    scope = Reward.scoped

    scope_applier(params, scope)
    .apply_order_to_scope
    .result
  end

end
