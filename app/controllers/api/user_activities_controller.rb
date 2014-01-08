class Api::UserActivitiesController < Api::ApiController
  respond_to :json

  def index
    offset = (params[:offset] || 0).to_i
    limit  = (params[:limit] || 200).to_i

    activities = User.find(params[:user_id]).activities.reverse.slice(offset, limit)

    @activities = ActivityDecorator.decorate_collection(activities || [])

    render 'api/activities/index'
  end

end
