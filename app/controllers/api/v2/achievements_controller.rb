class Api::V2::AchievementsController < Api::V2::BaseController
  before_filter :authenticate!
  load_and_authorize_resource

  def index
    @achievements = build_scope(request.env['muster.query']).result.all
    render :index
  end

  def create
    @achievement = Achievement.new(params[:achievement])
    if @achievement.save
      render :show
    else
      render :json => msg_hash(@achievement, 'create'), :status => 406
    end
  end

  def update
    @achievement = Achievement.find(params[:id])
    filtered_params = params.select {|param| Achievement.accessible_attributes.include?(param)}

    unless filtered_params["user"].nil?
      filtered_params["user"] = User.find(filtered_params["user"]["id"])
    end

    unless filtered_params["reward"].nil?
      filtered_params["reward"] = Reward.find(filtered_params["reward"]["id"])
    end

    if @achievement.update_attributes(filtered_params)
      render :show
    else
      render :json => msg_hash(@achievement, 'update'), :status => 406
    end
  end

  def destroy
    @achievement = Reward.find(params[:id])
    if @reward.destroy
      render :json => msg_hash(@achievement, 'destroy', 'success')
    else
      render :json => msg_hash(@achievement, 'destroy'), :status => 406
    end
  end

  # SCOPE BUILDING
  # --------------

  def logic_analyzer
    @logic_analyzer ||= QueryLogic::Query.new(Achievement, params)
  end

  def scope_applier(current_scope = nil)
    @scope_applier ||= ScopeApplier.new(current_scope || Achievement, logic_analyzer)
  end

  def build_scope(muster_query)
    scope = Achievement
    scope = scope_applier.apply_muster_query_to_scope(muster_query)
  end
end
