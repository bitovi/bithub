class Api::V1::UserActivitiesController < Api::V1::BaseController
  respond_to :json

  def index
    @activities = ActivityDecorator.decorate_collection(User.find(params[:user_id]).activities)
    render 'api/v1/activities/index'
  end

end
