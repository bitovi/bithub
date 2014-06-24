class Api::V2::CategoryDeterminationRulesController < Api::V2::BaseController
  before_filter :authenticate!
  load_and_authorize_resource

  respond_to :json

  def index
    @rules = CategoryDeterminationRule.all
  end

  def show
    @rule = CategoryDeterminationRule.find params[:id]
    render :show
  end

  def create
    @rule = CategoryDeterminationRule.new rule_params

    if @rule.save
      render :show
    else
      render :json => msg_hash(@rule, 'create'), :status => 406
    end
  end

  def update
    @rule = CategoryDeterminationRule.find params[:id]

    if @rule.update_attributes rule_params
      render :show
    else
      render :json => msg_hash(@rule, 'update'), :status => 406
    end
  end

  def destroy
    @rule = CategoryDeterminationRule.find params[:id]

    if @rule.destroy
      render :json => msg_hash(@rule, 'destroy', 'success')
    else
      render :json => msg_hash(@rule, 'destroy'), :status => 406
    end
  end

  private

  def rule_params
    params.require(:rule).permit(:name, :category_name, :required_tags => [])
  end

end
