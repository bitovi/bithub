class Api::V3::PlansController < Api::V3::BaseController
  before_filter :authenticate_account!, except: [:index, :show]
  load_and_authorize_resource

  def index
    @plans = Plan.all
    render :index
  end

  def show
    @plan = Plan.find plan_id
    render :show
  end

  private

  def plan_id
    params.require(:id)
  end
end
