class Api::V2::RewardsController < Api::V2::BaseController
  before_filter :authenticate!
  load_and_authorize_resource

  def index
    @rewards = build_scope.all
    @rewards_count = build_scope_for_counting.count
    render :index
  end

  def show
    @reward = Reward.find(params[:id])
    render :show
  end

  def create
    @reward = Reward.new(reward_params)
    if @reward.save
      render :show
    else
      render :json => msg_hash(@reward, 'create'), :status => 406
    end
  end

  def update
    @reward = Reward.find(params[:id])
    if @reward.update_attributes(reward_params)
      render :show
    else
      render :json => msg_hash(@reward, 'update'), :status => 406
    end
  end

  def destroy
    @reward = Reward.find(params[:id])
    if @reward.destroy
      render :json => msg_hash(@reward, 'destroy', 'success')
    else
      render :json => msg_hash(@reward, 'destroy'), :status => 406
    end
  end

  private

  def reward_params
    if params[:reward].is_a? String
      params[:reward] = Rack::Utils.parse_nested_query(params[:reward])
    end

    if params[:files]
      params[:reward][:image] = params[:files].first
    end

    params.require(:reward).permit(:title, :description, :point_minimum, :image, :disabled_ts)
  end

  def query_logic
    @logic_analyzer ||= QueryLogic::Query.new(Reward, params)
  end

  def scope_applier(current_scope = nil)
    @scope_applier ||= ScopeApplier.new(current_scope || Reward, query_logic)
  end

  def build_scope
    scope_applier.apply_order_to_scope.result
  end

  def build_scope_for_counting
    scope_applier\
      .apply_muster_query_to_scope(muster_query, skip_limits: true)\
      .apply_negated_attrs_to_scope\
      .apply_existence_attrs_to_scope\
      .apply_regular_params_to_scope\
      .result.offset(0).limit(1_000_000_000)
  end

end
