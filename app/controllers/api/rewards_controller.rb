class Api::RewardsController < Api::ApiController
  before_filter :authenticate_user!, except: [:index, :show]
  respond_to :json

  rescue_from ActiveRecord::RecordNotFound, with: :show_404
  rescue_from ActiveRecord::RecordInvalid, with: :show_406
  rescue_from CanCan::AccessDenied, with: :show_401

  def index
    scope = build_scope(request.env['muster.query'])
    scope = scope_applier.apply_order_to_scope(scope, params)
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

  def logic_analyzer
    @logic_analyzer ||= QueryLogicAnalyzer.new(Reward)
  end

  def scope_applier
    @scope_applier ||= ScopeApplier.new(logic_analyzer) 
  end

  def build_scope(muster_query)
    scope = Reward.scoped
    scope = scope_applier.apply_muster_query_to_scope(scope, muster_query)
  end

end
