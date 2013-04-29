class Admin::EventsController < Admin::AdminController
  def index
    @events = Event.page params[:page]
    render 'index'
  end
end
