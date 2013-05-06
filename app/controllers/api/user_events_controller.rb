class Api::UserEventsController < Api::ApiController
  def index
    @events = EventDecorator.decorate_collection(User.find(params[:user_id]).events)
    render 'api/events/index'
  end
end
