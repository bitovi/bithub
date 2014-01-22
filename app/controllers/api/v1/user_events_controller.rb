class Api::V1::UserEventsController < Api::V1::BaseController
  respond_to :json

  def index
    @events = EventDecorator.decorate_collection(User.find(params[:user_id]).events)
    render 'api/v1/events/index'
  end

end
