class Api::V2::ScoringRulesController < Api::V2::BaseController
  before_filter :authenticate!
  load_and_authorize_resource

  def index
    @rules = ScoringRule.all
    @scoring_rules_count = build_scope_for_counting(request.env['muster.query']).count
    render :index
  end

  def show
    @rule = ScoringRule.find params[:id]
    render :show
  end

  def create
    @rule = ScoringRule.new rule_params_on_post

    if @rule.save
      render :show
    else
      render :json => msg_hash(@rule, 'create'), :status => 406
    end
  end

  def update
    @rule = ScoringRule.find params[:id]

    if @rule.update_attributes rule_params_on_put
      render :show
    else
      render :json => msg_hash(@rule, 'update'), :status => 406
    end
  end

  def destroy
    @rule = ScoringRule.find params[:id]

    if @rule.invalidate
      render :json => msg_hash(@rule, 'destroy', 'success')
    else
      render :json => msg_hash(@rule, 'destroy'), :status => 406
    end
  end

  private
  
  def logic_analyzer
    @logic_analyzer ||= QueryLogic::Query.new(ScoringRule, params)
  end

  def scope_applier(current_scope = nil)
    @scope_applier ||= ScopeApplier.new(current_scope || ScoringRule, logic_analyzer)
  end

  def build_scope_for_counting(muster_query)
    scope_applier(ScoringRule)\
      .apply_muster_query_to_scope(muster_query, skip_limits: true)\
      .apply_negated_attrs_to_scope\
      .apply_existence_attrs_to_scope\
      .apply_regular_params_to_scope\
      .result.offset(0).limit(1_000_000_000)
  end

  def rule_params_on_post
    params.require(:rule).permit(:name, :authorship_value, :upvote_value, :award_value, :required_tags => [])
  end

  def rule_params_on_put
    params.require(:rule).permit(:name, :authorship_value, :upvote_value, :award_value)
  end
end
