class Api::V1::UserActivitiesController < Api::V1::BaseController
  respond_to :json

  def index
    offset = (params[:offset] || 0).to_i
    limit  = (params[:limit] || 200).to_i

    @activities = User.find(params[:user_id]).activities.order('ts DESC').slice(offset, limit)
    render 'api/v1/activities/index'
  end

end
