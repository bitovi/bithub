class Api::V1::AchievementsController < Api::V1::BaseController
  before_filter :authenticate_user!
  respond_to :json

  rescue_from ActiveRecord::RecordNotFound, with: :show_404
  rescue_from ActiveRecord::RecordInvalid, with: :show_406
  rescue_from CanCan::AccessDenied, with: :show_401

  def index
    authorize! :read, Achievement, :message => "No rights to read achievements."
    @achievements = build_scope(request.env['muster.query']).all
    render :index
  end

  def create
    authorize! :manage, Achievement, :message => "No rights to manage achievements."
    @achievement = Achievement.new(params[:achievement])
    if @achievement.save
      render :show
    else
      render :json => msg_hash(@achievement, 'create'), :status => 406
    end
  end

  def update
    authorize! :manage, Achievement, :message => "No rights to manage achievements."

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
    authorize! :manage, Reward, :message => "No rights to manage rewards."
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
    @scope_applier ||= ScopeApplier.new(current_scope || Achievement.scoped, logic_analyzer)
  end

  def build_scope(muster_query)
    scope = Achievement.scoped
    scope = profile_completed_or_not(scope)
    scope_applier(scope)
      .apply_muster_query_to_scope(muster_query)
      .apply_negated_attrs_to_scope
      .apply_existence_attrs_to_scope
      .apply_regular_params_to_scope
      .apply_order_to_scope
      .result
  end

  def profile_completed_or_not(scope)
    if params[:profile_completed]
      scope = scope.joins(:user).where(CompletedProfileString)
    elsif params[:profile_not_completed]
      scope = scope.joins(:user).where(NotCompletedProfileString)
    end
    scope
  end

  CompletedProfileString = "users.name IS NOT NULL and users.email IS NOT NULL and users.address IS NOT NULL and users.city IS NOT NULL and users.postal IS NOT NULL"
  NotCompletedProfileString = "users.name IS NULL and users.email IS NULL and users.address IS NULL and users.city IS NULL and users.postal IS NULL"
end
