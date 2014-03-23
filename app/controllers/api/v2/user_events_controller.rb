class Api::V2::UserEventsController < Api::V2::BaseController
  respond_to :json

  def index
    @events = EventDecorator.decorate_collection(User.find(params[:user_id]).events)
    render 'api/v2/events/index'
  end

end
