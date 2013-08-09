class Api::UserEventsController < Api::ApiController
  respond_to :json

  def index
    @events = EventDecorator.decorate_collection(User.find(params[:user_id]).events)
    render 'api/events/index'
  end

end
