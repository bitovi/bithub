class Api::V2::ScoringRulesController < Api::V2::BaseController
  respond_to :json

  rescue_from ActiveRecord::RecordNotFound, with: :show_404
  rescue_from ActiveRecord::RecordInvalid, with: :show_406

  def index
    @rules = ScoringRule.all
    render :index
  end

  def show
    @rule = ScoringRule.find(params[:id])
    render :show
  end

  def create
    @rule = ScoringRule.new(rule_params)
    if @rule.save
      render :show
    else
      render :json => msg_hash(@rule, 'create'), :status => 406
    end
  end

  def update
    # @rule = ScoringRule.find(params[:id])

    # if @rule.update_attributes(rule_params)
    #   render :show
    # else
    #   render :json => msg_hash(@rule, 'update'), :status => 406
    # end


    @rule = ScoringRule
      .where({:name => rule_params[:name]})
      .where("required_tags = ?", rule_params[:required_tags].to_posgres_array(true))
      .first

    @rule ||= Rule.new

    if @rule.update_attributes(rule_params)
      render :show
    else
      render :json => msg_hash(@rule, 'update'), :status => 406
    end
  end

  def destroy
    @rule = ScoringRule.find(params[:id])
    if @rule.destroy
      render :json => msg_hash(@rule, 'destroy', 'success')
    else
      render :json => msg_hash(@rule, 'destroy'), :status => 406
    end
  end

  private

  def rule_params
    params.require(:rule).permit(:name, :authorship_value, :upvote_value, :award_value, :priority, :valid_until, required_tags: [])
  end

end
