class Api::V3::PlansController < Api::V3::BaseController
  before_filter :authenticate_account!, except: [:index, :show]
  load_and_authorize_resource

  def index
    authorize! :index, Plan
    render :index
  end

  def show
    authorize! :show, a_plan
    render :show
  end

  private

  def all_plans
    @plans = Plan.where(available: true).all
  end

  def a_plan
    @plan = Plan.find plan_id
  end

  def plan_id
    params.require(:id)
  end
end
