class Api::V2::AchievementsController < Api::V2::BaseController
  before_filter :authenticate!
  load_and_authorize_resource

  def index
    @achievements = build_scope.all
    @achievements_count = build_scope_for_counting.count
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

  def build_scope
    scope = Achievement
    scope = profile_completed_or_not(scope)
    scope_applier(scope)\
      .apply_muster_query_to_scope(muster_query)\
      .apply_negated_attrs_to_scope\
      .apply_existence_attrs_to_scope\
      .apply_regular_params_to_scope\
      .apply_order_to_scope\
      .result
  end

  def build_scope_for_counting
    scope = Achievement
    scope_applier(scope)\
      .apply_muster_query_to_scope(muster_query, skip_limits: true)\
      .apply_negated_attrs_to_scope\
      .apply_existence_attrs_to_scope\
      .apply_regular_params_to_scope\
      .result.offset(0).limit(1_000_000_000)
  end

  def profile_completed_or_not(scope)
    scope = scope.joins(:user).order("users.name ASC").order("shipped_at DESC")

    if params[:profile_completed]
      scope = scope.where(CompletedProfileString)
    elsif params[:profile_not_completed]
      scope = scope.where(NotCompletedProfileString)
    end

    scope
  end

  Columns = %w(name email address city postal)

  CompletedProfileString = (Columns.map{|c| "users.#{c} IS NOT NULL" } + Columns.map{|c| "users.#{c} <> ''"} + Columns.map {|c| "users.#{c} <> 'null'"}).join(" AND ")
  NotCompletedProfileString = (Columns.map{|c| "users.#{c} IS NULL"} + Columns.map{|c| "users.#{c} = ''"}).join(" OR ")

end
