class Api::UserActivitiesController < Api::ApiController
  def index
    @activities = ActivityDecorator.decorate_collection(User.find(params[:user_id]).activities)
    render 'api/activities/index'
  end
end
